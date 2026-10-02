-- easel session "contact2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen={18,16}, seed=4417, ground={{pile={{"lead white",6},{"yellow ochre",1},{"ultramarine ash",1},{"bone black",0.15}}, um=120, apply="knife", texture=0.15}}}
print(W,H)

--@ chunk 2
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

--@ chunk 3
function sx(y) return 540 - 0.064*y end
LM = poly({{-5,-5},{sx(-5),-5},{sx(630),630},{-5,630}})
RM = -LM
-- his side: dark grimy wall, lit by a raking warm light from upper left
WD = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
WM = pile{{"bone black",1.2},{"burnt sienna",1},{"ultramarine ash",1},{"raw sienna",0.4},{"lead white",0.25}}
WL = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.4},{"raw sienna",0.5},{"yellow ochre",0.3}}
work(LM, {hand="broad", pile=WD, coverage=3, fill=true, clip=true, angle=-0.5})
local lit = (ellipse(160, 120, 330, 220):blur(80)) * LM
work(lit, {hand="body", pile=WM, coverage=2.2, fill=true, clip=LM, angle=-0.6, threshold=0.35})
local lit2 = (ellipse(120, 90, 200, 130):blur(60)) * LM
work(lit2, {hand="body", pile=WL, coverage=1.6, clip=LM, angle=-0.6, threshold=0.4})
-- her side: one flat, even, pale luminous field
PF = pile{{"zinc white",6},{"cerulean blue",0.35},{"cobalt violet",0.1}}
work(RM, {hand="body", pile=PF, coverage=4, fill=true, clip=true, angle=0, ruler=true, length={60,120}})

--@ chunk 4
print(wait(2*24*60))
-- the wall: darken and break up the olive patch with grimy cool-warm darks, panel lay-in
local W2 = pile{{"bone black",1.5},{"burnt sienna",1},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.12}}
local W3 = pile{{"bone black",1},{"Mars brown",1},{"ultramarine ash",1.2},{"yellow ochre",0.3},{"lead white",0.3}}
work(LM, {hand="body", pile=W2, coverage=2.4, fill=true, clip=true, angle=-0.4, threshold=0.3})
local lit = (ellipse(140, 90, 300, 170):blur(70)) * LM
work(lit, {hand="scumble", pile=W3, coverage=1.4, clip=LM, threshold=0.45})

--@ chunk 5
print(wait(24*60))
TG = pile{{"bone black",1},{"ultramarine ash",1.5},{"lead white",0.45},{"raw sienna",0.3}}
TGd = pile{{"bone black",1.4},{"ultramarine ash",1},{"burnt sienna",0.4},{"lead white",0.15}}
TL = pile{{"lead white",2},{"yellow ochre",1},{"ultramarine ash",0.6},{"raw sienna",0.2}}
WD2 = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.7}}
-- the terminal housing (his half)
HOUS = poly({{255,175},{620,175},{620,505},{255,505}}) * LM
-- cast shadow of the housing on the wall, down-right
local sh = (poly({{255,175},{620,175},{620,505},{255,505}}):offset(0))
local shad = poly({{270,505},{620,505},{620,530},{290,530}}) * LM
work(shad, {hand="body", pile=WD2, coverage=3, fill=true, clip=true, angle=0})
work(HOUS, {hand="body", pile=TG, coverage=3.5, fill=true, clip=true, angle=0.05, length={30,80}})
-- lower part of the face falls a little darker (light rakes from above)
local low = poly({{255,400},{620,400},{620,505},{255,505}}) * LM
work(low, {hand="body", pile=TGd, coverage=1.6, clip=HOUS, angle=0.05, edge="soft"})
-- lit top bevel and left bevel
local topb = poly({{250,170},{620,170},{620,183},{262,183}}) * LM
work(topb, {hand="detail", pile=TL, coverage=3, fill=true, angle=0})
local leftb = poly({{250,170},{262,183},{262,505},{250,505}})
work(leftb, {hand="detail", pile=TL, coverage=2.5, fill=true, angle=math.pi/2})

--@ chunk 6
AM = pile{{"bone black",1},{"ultramarine ash",0.8},{"burnt sienna",0.5},{"lead white",0.35}}
AL = pile{{"lead white",1.5},{"yellow ochre",0.8},{"ultramarine ash",0.5},{"bone black",0.2}}
AD = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.5}}
AH = pile{{"lead white",3},{"yellow ochre",0.5}}
AC = pile{{"zinc white",2},{"cerulean blue",1}}

-- geometry along an axis: point at t (0..1) offset s (-1..1 of half width; +1 = upper-left side)
function axpt(P0, P1, w0, w1, t, s)
  local dx, dy = P1[1]-P0[1], P1[2]-P0[2]
  local L = math.sqrt(dx*dx+dy*dy)
  local ux, uy = dx/L, dy/L
  local nx, ny = uy, -ux          -- left normal of the direction
  if nx*(-1) + ny*(-1) < 0 then nx, ny = -nx, -ny end  -- point toward upper-left
  local w = lerp(w0, w1, t)
  return {P0[1] + dx*t + nx*w*s, P0[2] + dy*t + ny*w*s}
end
function segpoly(P0, P1, w0, w1, s0, s1, t0, t1)
  local pts = {}
  for i = 0, 6 do local t = lerp(t0 or 0, t1 or 1, i/6); pts[#pts+1] = axpt(P0,P1,w0,w1,t,s1) end
  for i = 6, 0, -1 do local t = lerp(t0 or 0, t1 or 1, i/6); pts[#pts+1] = axpt(P0,P1,w0,w1,t,s0) end
  return poly(pts, true)
end
-- one armour segment, modelled wet-into-wet: base, lit side, shadow side, rim, cool reflected edge
function armseg(P0, P1, w0, w1, o)
  o = o or {}
  local ang = math.atan(P1[2]-P0[2], P1[1]-P0[1]) + math.pi/2
  local whole = segpoly(P0,P1,w0,w1,-1,1)
  work(whole, {hand="body", pile=o.base or AM, coverage=3, fill=true, clip=true, angle=ang, length={8,30}, tool="filbert 6"})
  work(segpoly(P0,P1,w0,w1,0.25,1) * whole, {hand="body", pile=o.lit or AL, coverage=1.5, clip=whole, angle=ang, length={6,20}, tool="filbert 4", edge="soft"})
  work(segpoly(P0,P1,w0,w1,-1,-0.45) * whole, {hand="body", pile=AD, coverage=1.5, clip=whole, angle=ang, length={6,20}, tool="filbert 4", edge="soft"})
  local b = brush{kind="round", width=2.4, point=0.7}
  b:load(o.hi or AH, 0.8)
  local rim = {}
  for i = 0, 8 do rim[#rim+1] = axpt(P0,P1,w0*0.93,w1*0.93,lerp(0.06,0.94,i/8),1) end
  b:stroke(rim, {pressure={0.35,0.6}, ramps={0.2,0.3}, swell={0.6,1,0.8}})
  if o.cool ~= false then
    local c = brush{kind="round", width=1.8, point=0.8}
    c:load(AC, 0.6)
    local re = {}
    for i = 0, 8 do re[#re+1] = axpt(P0,P1,w0*0.95,w1*0.95,lerp(0.15,0.95,i/8),-1) end
    c:stroke(re, {pressure={0.2,0.45}, ramps={0.3,0.2}})
  end
  return whole
end

-- the forearm: three overlapping vambrace plates, nearest the elbow first
local A, B = {40, 660}, {340, 405}
local function at(t) return {lerp(A[1],B[1],t), lerp(A[2],B[2],t)} end
armseg(at(0.0), at(0.42), 78, 72)
armseg(at(0.36), at(0.74), 72, 64)
armseg(at(0.68), at(1.0), 62, 52)

--@ chunk 7
print(wait(30*60))
-- value ramp across a cylinder raked from upper left (s=+1 is the lit upper-left edge)
R1 = pile{{"bone black",1.2},{"ultramarine ash",1},{"cerulean blue",0.3},{"lead white",0.5}}   -- cool reflected
R2 = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.5}}                       -- core shadow
R3 = pile{{"bone black",1.4},{"burnt sienna",0.6},{"ultramarine ash",0.8},{"lead white",0.25}}  -- shadow side
R4 = pile{{"bone black",1},{"raw sienna",0.6},{"ultramarine ash",0.8},{"lead white",0.5}}       -- half tone
R5 = pile{{"bone black",0.5},{"yellow ochre",0.7},{"ultramarine ash",0.6},{"lead white",0.9}}   -- light
R6 = pile{{"lead white",1.6},{"yellow ochre",0.7},{"ultramarine ash",0.3},{"bone black",0.1}}   -- top light
RAMP = {{-1,-0.78,R1},{-0.82,-0.25,R2},{-0.3,0.2,R3},{0.15,0.5,R4},{0.45,0.78,R5},{0.74,1,R6}}
function tubeg(P0, P1, w0, w1, o)
  o = o or {}
  local ang = math.atan(P1[2]-P0[2], P1[1]-P0[1]) + math.pi/2
  local whole = segpoly(P0,P1,w0,w1,-1,1)
  for _, r in ipairs(o.ramp or RAMP) do
    local m = segpoly(P0,P1,w0*1.02,w1*1.02,r[1],r[2]) * whole
    work(m, {hand="body", pile=r[3], coverage=o.cov or 2.6, fill=true, clip=whole, angle=ang, length={6,22}, tool=o.tool or "filbert 5", angle_jitter=0.15, threshold=0.4})
  end
  if o.rim ~= false then
    local b = brush{kind="round", width=2.2, point=0.7}
    b:load(AH, 0.7)
    local rim = {}
    for i = 0, 8 do rim[#rim+1] = axpt(P0,P1,w0*0.95,w1*0.95,lerp(0.08,0.92,i/8),1) end
    b:stroke(rim, {pressure={0.3,0.55}, ramps={0.25,0.3}, swell={0.5,1,0.7}, shake=1})
  end
  return whole
end
local A, B = {30, 680}, {345, 400}
local function at(t) return {lerp(A[1],B[1],t), lerp(A[2],B[2],t)} end
FA1 = tubeg(at(0.0), at(0.45), 95, 86)

--@ chunk 8
R4 = pile{{"bone black",1.2},{"raw sienna",0.6},{"ultramarine ash",0.8},{"lead white",0.35}}
R5 = pile{{"bone black",0.6},{"yellow ochre",0.7},{"ultramarine ash",0.6},{"lead white",0.6}}
RAMP = {{-1,-0.8,R1},{-0.84,-0.05,R2},{-0.1,0.32,R3},{0.28,0.62,R4},{0.58,0.88,R5},{0.84,1,R6}}
local A, B = {30, 680}, {345, 400}
local function at(t) return {lerp(A[1],B[1],t), lerp(A[2],B[2],t)} end
FA1 = tubeg(at(0.0), at(0.45), 95, 86)
FA2 = tubeg(at(0.40), at(0.76), 88, 76)
FA3 = tubeg(at(0.71), at(1.0), 77, 62)

--@ chunk 9
-- cable (rubber black, cool reflections), falling from under the fist to the bottom edge
local K1 = pile{{"bone black",2},{"ultramarine blue",0.4}}
local K2 = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.25}}
local K3 = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.7},{"yellow ochre",0.2}}
local KR = {{-1,-0.7,R1},{-0.75,0.3,K1},{0.25,0.7,K2},{0.65,1,K3}}
local pts = {{395,385},{420,450},{450,520},{468,580},{474,640}}
for i = 1, #pts-1 do tubeg(pts[i], pts[i+1], 15, 15, {ramp=KR, rim=false, tool="filbert 4"}) end
-- plug body (dull steel) from inside the fist to the socket
PS1 = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.3}}
PS2 = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.8}}
PS3 = pile{{"lead white",2},{"ultramarine ash",0.6},{"yellow ochre",0.3}}
PSR = {{-1,-0.7,R1},{-0.75,0.0,PS1},{-0.05,0.6,PS2},{0.55,1,PS3}}
tubeg({440,330},{508,330}, 22, 21, {ramp=PSR, tool="filbert 4"})
tubeg({506,330},{524,330}, 14, 14, {ramp=PSR, tool="filbert 3", rim=false})
-- amber hazard collar on the plug
local AMB = pile{{"Mars orange",2},{"cadmium yellow",1},{"raw sienna",0.5}}
local AMBd = pile{{"Mars orange",1},{"burnt sienna",1},{"bone black",0.3}}
local col = rect(478, 308, 12, 44) * segpoly({440,330},{508,330},22,21,-1,1)
work(col, {hand="detail", pile=AMB, coverage=3, fill=true})
work(col * rect(470,334,30,20), {hand="detail", pile=AMBd, coverage=2, fill=true})
-- ribs: dark grooves across the plug
local g = brush{kind="round", width=1.6, point=0.5}
for _, x in ipairs({494, 499, 504}) do
  g:load(R2, 0.8); g:stroke({{x,310},{x+0.5,350}}, {pressure={0.5,0.5}, ramps={0.1,0.1}})
end

--@ chunk 10
-- back of the gauntlet, continuing the forearm toward the plug
HB = tubeg({330,418},{402,318}, 56, 46, {tool="filbert 4"})
-- four armoured fingers wrapping down over the plug's near side
FING = {}
local xs = {{410,4},{431,2},{451,-1},{469,-3}}
for i, f in ipairs(xs) do
  local x, lean = f[1], f[2]
  local w = (i == 4) and 8.5 or 10
  FING[i] = tubeg({x - lean, 296 + i*1.5}, {x + lean, 360 + i*2}, w, w*0.9, {tool="filbert 3", cov=2.8})
end
-- knuckle plates: a row of small domes along the top of the fist
for i, f in ipairs(xs) do
  local x = f[1] - f[2]
  tubeg({x-9, 300 + i*1.5}, {x+9, 300 + i*1.5}, 7, 7, {tool="filbert 3", rim=true})
end

--@ chunk 11
-- the fist's mass joining the gauntlet back to the fingers
local blk = poly({{352,330},{372,296},{400,286},{416,292},{418,362},{398,380},{368,382},{350,360}}, true)
work(blk, {hand="body", pile=R3, coverage=3, fill=true, clip=true, angle=0.9, tool="filbert 4", length={6,18}})
local top = blk * poly({{340,280},{425,280},{425,310},{340,345}})
work(top, {hand="body", pile=R5, coverage=2, fill=true, clip=blk, angle=0.9, tool="filbert 3", length={5,14}, edge="soft"})
local bot = blk * poly({{340,370},{425,345},{425,390},{340,390}})
work(bot, {hand="body", pile=R2, coverage=2, fill=true, clip=blk, angle=0.9, tool="filbert 3", length={5,14}, edge="soft"})
local b = brush{kind="round", width=2.2, point=0.7}
b:load(AH, 0.7)
b:stroke({{356,326},{372,298},{398,289},{414,293}}, {pressure={0.3,0.5}, ramps={0.2,0.3}, shake=1})
-- dark gap between fist block and first finger
local d = brush{kind="round", width=2, point=0.6}
d:load(R2, 0.9)
d:stroke({{418,296},{419,330},{417,362}}, {pressure={0.5,0.4}})

--@ chunk 12
print(drying(800,300), drying(700,500), drying(400,330), drying(200,500))

--@ chunk 13
print(wait(3*24*60))
print(drying(800,300), drying(560,400))
-- her side: a ruled construction grid, drawn in graphite against a ruler
local h = pencil("2H")
for x = 550, 990, 25 do
  h:rule({x, 0}, {x, 625}, {pressure=0.32})
  if x % 100 == 50 then h:sharpen() end
end
for y = 15, 615, 25 do
  h:rule({sx(y) + 4, y}, {1000, y}, {pressure=0.32})
end

--@ chunk 14
print(wait(4*24*60))
print(drying(800,300), drying(560,400), drying(200,500))
PF2 = pile{{"zinc white",6},{"lead white",1},{"cerulean blue",0.35},{"cobalt violet",0.12}}
work(RM, {hand="body", pile=PF2, coverage=4.5, fill=true, clip=true, angle=0, ruler=true, length={80,160}, tool="flat 10", pressure={0.5,0.7}})
print(wait(3*24*60))
print(drying(800,300))

--@ chunk 15
print(wait(10*24*60))
print(drying(800,300), drying(700,500))
GC = pile{{"zinc white",3},{"cerulean blue",1.2},{"cobalt blue",0.3}}
local r = brush{kind="round", width=1.3, point=0.6}
local function ruled(x0, y0, x1, y1)
  local L = math.sqrt((x1-x0)^2 + (y1-y0)^2)
  local n = math.max(1, math.ceil(L / 110))
  for i = 0, n-1 do
    local a, b = i/n, math.min(1, (i+1)/n + 0.01)
    r:load(GC, 0.9)
    r:stroke({{lerp(x0,x1,a), lerp(y0,y1,a)}, {lerp(x0,x1,b), lerp(y0,y1,b)}}, {pressure={0.55,0.55}, ramps={0.01,0.01}, shake=0})
  end
end
for x = 550, 990, 25 do ruled(x, 0, x, 625) end
for y = 15, 615, 25 do ruled(sx(y) + 3, y, 1000, y) end

--@ chunk 16
INK = pile{{"ultramarine blue",1},{"bone black",0.5},{"cobalt violet",0.3}}
local tops = {
 pile{{"zinc white",3},{"cerulean blue",1.3}},
 pile{{"zinc white",3},{"cobalt violet",1.2},{"cobalt blue",0.15}},
 pile{{"zinc white",3},{"magenta",0.35},{"lead white",0.5}},
 pile{{"zinc white",3},{"emerald green",0.7},{"cerulean blue",0.5}},
 pile{{"zinc white",3},{"lemon chrome",0.6}},
}
local fronts = {
 pile{{"zinc white",1.5},{"cerulean blue",1.3},{"cobalt blue",0.4}},
 pile{{"zinc white",1.5},{"cobalt violet",1.3},{"ultramarine blue",0.25}},
 pile{{"zinc white",1.5},{"magenta",0.6},{"cobalt violet",0.3}},
 pile{{"zinc white",1.5},{"emerald green",0.9},{"cerulean blue",0.7}},
 pile{{"zinc white",1.5},{"lemon chrome",0.6},{"Indian yellow",0.3}},
}
local SHC = pile{{"zinc white",3},{"cobalt violet",0.5},{"ultramarine ash",0.6}}
local ink = brush{kind="round", width=1.2, point=0.6}
local function rule(p, q)
  ink:load(INK, 0.9)
  ink:stroke({p, q}, {pressure={0.5,0.5}, ramps={0.01,0.01}, shake=0})
end
PLATES = {}
for i = 1, 10 do
  local t = (i-1)/9
  local cx, cy = lerp(690, 830, t), lerp(452, 268, t)
  local w, d = lerp(250, 110, t), lerp(56, 26, t)
  local k = 0.5*d
  local th = lerp(7, 4, t)
  local FL, FR = {cx-w/2, cy+d/2}, {cx+w/2, cy+d/2}
  local BR, BL = {cx+w/2+k, cy-d/2}, {cx-w/2+k, cy-d/2}
  local top = poly({FL, FR, BR, BL})
  local front = poly({FL, FR, {FR[1], FR[2]+th}, {FL[1], FL[2]+th}})
  local side = poly({FR, BR, {BR[1], BR[2]+th}, {FR[1], FR[2]+th}})
  local shadow = poly({{FL[1]+9, FL[2]+th+2}, {FR[1]+9, FR[2]+th+2}, {BR[1]+9, BR[2]+th+2}, {BR[1]+9, BR[2]+12}, {FR[1]+9, FR[2]+th+12}, {FL[1]+9, FL[2]+th+12}})
  local ci = (i-1) % 5 + 1
  work(shadow - top - front - side, {hand="body", pile=SHC, coverage=3, fill=true, clip=true, angle=0, ruler=true, tool="filbert 5"})
  work(top, {hand="body", pile=tops[ci], coverage=3.5, fill=true, clip=true, angle=0, ruler=true, tool="filbert 6"})
  work(front + side, {hand="detail", pile=fronts[ci], coverage=3, fill=true, angle=0})
  rule(FL, FR); rule(FR, BR); rule(BR, BL); rule(BL, FL)
  rule({FL[1], FL[2]+th}, {FR[1], FR[2]+th}); rule({FR[1], FR[2]+th}, {BR[1], BR[2]+th})
  rule(FL, {FL[1], FL[2]+th}); rule(FR, {FR[1], FR[2]+th}); rule(BR, {BR[1], BR[2]+th})
  PLATES[i] = {FL=FL, FR=FR, BR=BR, BL=BL, th=th, cx=cx, cy=cy, w=w, d=d}
end

--@ chunk 17
-- Ratio's avatar: a chibi low-poly girl, flat-shaded facets, standing alone on the topmost layer
local HAIR1 = pile{{"bone black",1.5},{"ultramarine blue",0.8}}
local HAIR2 = pile{{"bone black",1},{"ultramarine blue",1},{"cobalt violet",0.3},{"zinc white",0.25}}
local SKIN1 = pile{{"zinc white",4},{"lead white",1},{"magenta",0.06},{"yellow ochre",0.05}}
local SKIN2 = pile{{"zinc white",3},{"cobalt violet",0.3},{"magenta",0.06}}
local DRS1 = pile{{"zinc white",4},{"cerulean blue",0.3}}
local DRS2 = pile{{"zinc white",2},{"cerulean blue",0.8},{"cobalt blue",0.2}}
local function facet(pts, p, cov)
  work(poly(pts), {hand="detail", pile=p, coverage=cov or 3.5, fill=true, angle=0, tool={kind="round", width=1.8}})
end
-- long hair behind, two facets
facet({{846,146},{878,158},{889,200},{886,264},{868,252},{858,266},{846,256}}, HAIR1)
facet({{846,146},{846,256},{834,266},{822,252},{805,262},{802,200},{812,158}}, HAIR2)
-- body: a small dress, lit facet left, shaded right
facet({{845,212},{845,258},{826,258}}, DRS1)
facet({{835,212},{845,212},{826,258}}, DRS1)
facet({{845,212},{857,212},{865,258},{845,258}}, DRS2)
-- arms
facet({{834,216},{826,240},{830,242},{837,222}}, SKIN1)
facet({{856,216},{864,240},{860,242},{853,222}}, SKIN2)
-- legs and shoes
facet({{836,258},{843,258},{842,270},{837,270}}, SKIN1)
facet({{848,258},{855,258},{854,270},{849,270}}, SKIN2)
facet({{834,269},{843,269},{843,275},{833,275}}, HAIR1)
facet({{848,269},{857,269},{858,275},{848,275}}, HAIR1)
-- face: two facets
facet({{845,172},{845,215},{834,214},{822,200},{823,178}}, SKIN1)
facet({{845,172},{867,178},{868,200},{857,214},{845,215}}, SKIN2)
-- bangs: a fringe of dark triangles over the brow
facet({{818,174},{846,153},{874,174},{868,190},{860,180},{853,192},{846,180},{839,192},{832,180},{824,190}}, HAIR1)
-- eyes: tall dark hexagons with a cyan glint
facet({{834,193},{839,191},{840,201},{835,204},{832,199}}, HAIR1, 4)
facet({{851,191},{856,193},{858,199},{855,204},{850,201}}, HAIR1, 4)
local g = brush{kind="round", width=1.6, point=0.3}
g:load(pile{{"zinc white",2},{"cerulean blue",1}}, 0.8)
g:touch(836.5, 195, {pressure=0.5}); g:touch(853.5, 195, {pressure=0.5})

--@ chunk 18
print(wait(8*24*60))
print(drying(810,230), drying(845,200), drying(845,240))

--@ chunk 19
print(wait(12*24*60)); print(drying(810,230), drying(845,200), drying(845,240), drying(300,500), drying(420,330))

--@ chunk 20
local HAIR1 = pile{{"bone black",1.5},{"ultramarine blue",0.8}}
local SKIN1 = pile{{"zinc white",4},{"lead white",1.5},{"magenta",0.06},{"yellow ochre",0.05}}
local SKIN2 = pile{{"zinc white",3},{"lead white",1},{"cobalt violet",0.35},{"magenta",0.06}}
local DRS1 = pile{{"zinc white",4},{"lead white",1},{"cerulean blue",0.3}}
local DRS2 = pile{{"zinc white",2},{"lead white",0.5},{"cerulean blue",0.8},{"cobalt blue",0.2}}
local newhair = poly({{846,146},{868,151},{882,166},{888,200},{885,238},{879,266},{866,250},{858,266},{846,256},{834,266},{824,250},{811,266},{805,238},{802,200},{809,166},{824,151}})
local old = rect(798, 142, 96, 128) * RM
local clear = old - newhair - poly({{770,252},{900,252},{900,290},{770,290}})
work(clear, {hand="detail", pile=PF2, coverage=5, fill=true, angle=0, tool={kind="round", width=2}})
local r = brush{kind="round", width=1.3, point=0.6}
for _, x in ipairs({800, 825, 850, 875, 900}) do r:load(GC, 0.9); r:stroke({{x,140},{x,272}}, {pressure={0.55,0.55}, ramps={0.01,0.01}, shake=0, clip=clear}) end
for _, y in ipairs({140, 165, 190, 215, 240, 265}) do r:load(GC, 0.9); r:stroke({{796,y},{900,y}}, {pressure={0.55,0.55}, ramps={0.01,0.01}, shake=0, clip=clear}) end
local function facet(pts, p, cov)
  work(poly(pts), {hand="detail", pile=p, coverage=cov or 5, fill=true, angle=0, tool={kind="round", width=1.8}})
end
facet({{845,212},{845,258},{826,258}}, DRS1)
facet({{835,212},{845,212},{826,258}}, DRS1)
facet({{845,212},{857,212},{865,258},{845,258}}, DRS2)
facet({{834,216},{826,240},{830,242},{837,222}}, SKIN1)
facet({{856,216},{864,240},{860,242},{853,222}}, SKIN2)
facet({{836,258},{843,258},{842,270},{837,270}}, SKIN1)
facet({{848,258},{855,258},{854,270},{849,270}}, SKIN2)
facet({{845,176},{845,215},{834,214},{822,200},{823,182}}, SKIN1)
facet({{845,176},{867,182},{868,200},{857,214},{845,215}}, SKIN2)

--@ chunk 21
print(wait(10*24*60))
print(drying(840,195))
local HAIR1 = pile{{"bone black",1.5},{"ultramarine blue",0.8}}
local function facet(pts, p, cov)
  work(poly(pts), {hand="detail", pile=p, coverage=cov or 5, fill=true, angle=0, tool={kind="round", width=1.6}})
end
facet({{821,184},{825,168},{846,158},{867,168},{869,186},{862,179},{856,192},{849,180},{842,192},{835,180},{828,190}}, HAIR1)
facet({{831,195},{838,193},{840,203},{835,207},{830,202}}, HAIR1)
facet({{851,193},{858,195},{859,202},{854,207},{850,203}}, HAIR1)
local g = brush{kind="round", width=1.8, point=0.3}
g:load(pile{{"zinc white",2},{"cerulean blue",1.2}}, 0.8)
g:touch(834, 197, {pressure=0.55}); g:touch(853.5, 197, {pressure=0.55})
local m = brush{kind="round", width=1.2, point=0.8}
m:load(pile{{"zinc white",1},{"magenta",0.5}}, 0.6)
m:stroke({{843,210},{847,210.5}}, {pressure={0.4,0.4}})
-- dark overlay box of his annotation, and her speech bubble, and a dashboard panel
NAVY = pile{{"bone black",1.5},{"ultramarine blue",1}}
work(rect(548, 26, 340, 66), {hand="body", pile=NAVY, coverage=4, fill=true, clip=true, angle=0, ruler=true, tool="filbert 6"})
local WHT = pile{{"zinc white",4},{"lead white",2}}
BUB = poly({{692,150},{806,150},{806,182},{790,182},{818,198},{778,182},{692,182}})
work(BUB, {hand="detail", pile=WHT, coverage=5, fill=true, angle=0, tool={kind="round", width=2}})
DASH = rect(768, 478, 216, 128)
work(DASH, {hand="body", pile=WHT, coverage=4, fill=true, clip=true, angle=0, ruler=true, tool="filbert 6"})

--@ chunk 22
-- his wall: rebuilt dark and grimy, raked by a warm light from the upper left
local armzone = segpoly({30,680},{345,400},100,66,-1,1):grow(4) + poly({{330,280},{420,280},{480,300},{480,370},{420,400},{330,430}}):grow(2)
local cable = ribbon({{395,385},{420,450},{450,520},{468,580},{474,640}}, 34)
TERMZ = rect(249, 169, 300, 338)
WALL = LM - TERMZ - armzone - cable - rect(430,300,95,60)
local d = mask(function(x, y) return math.sqrt((x+120)^2 + (y+80)^2) end)
WA = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine ash",1},{"yellow ochre",0.4},{"lead white",0.45}}
WB = pile{{"bone black",1.4},{"burnt sienna",0.8},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.18}}
WC = pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.6}}
local near = WALL * d:map(function(v) return 1 - smoothstep(330, 420, v) end)
local mid  = WALL * d:map(function(v) return smoothstep(300, 380, v) * (1 - smoothstep(520, 600, v)) end)
local far  = WALL * d:map(function(v) return smoothstep(500, 580, v) end)
work(far,  {hand="body", pile=WC, coverage=3, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}})
work(mid,  {hand="body", pile=WB, coverage=3, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}})
work(near, {hand="body", pile=WA, coverage=3, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}})

--@ chunk 23
print(wait(3*24*60))
print(drying(200,600), drying(100,100))
local d = mask(function(x, y) return math.sqrt((x+120)^2 + (y+80)^2) end)
WC2 = pile{{"bone black",2},{"Mars brown",0.6},{"ultramarine blue",0.8}}
WB2 = pile{{"bone black",1.5},{"burnt sienna",0.8},{"ultramarine ash",0.8},{"raw sienna",0.3}}
local far  = WALL * d:map(function(v) return smoothstep(430, 560, v) end)
local mid  = WALL * d:map(function(v) return smoothstep(300, 380, v) * (1 - smoothstep(470, 540, v)) end)
work(far, {hand="body", pile=WC2, coverage=5, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}, load=1, pressure={0.7,0.95}, threshold=0.3})
work(mid, {hand="body", pile=WB2, coverage=4, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}, load=1, pressure={0.7,0.95}, threshold=0.3})

--@ chunk 24
local function D(x, y) return math.sqrt((x+120)^2 + (y+80)^2) end
local far = WALL * mask(function(x, y) return smoothstep(400, 520, D(x,y)) end)
local mid = WALL * mask(function(x, y) local v = D(x,y); return smoothstep(270, 340, v) * (1 - smoothstep(430, 500, v)) end)
work(far, {hand="body", pile=WC2, coverage=5, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}, load=1, pressure={0.7,0.95}, threshold=0.3})
work(mid, {hand="body", pile=WB2, coverage=4, fill=true, clip=WALL, angle=-0.35, tool="filbert 8", length={20,60}, load=1, pressure={0.7,0.95}, threshold=0.3})

--@ chunk 25
ARMZ = segpoly({30,680},{345,400},100,66,-1,1):grow(3) + poly({{330,280},{420,280},{480,300},{480,370},{420,400},{330,430}}):grow(1)
CABZ = ribbon({{395,385},{420,450},{450,520},{468,580},{474,640}}, 34)
PLUGZ = rect(430,305,95,52)
FRONT = ARMZ + CABZ + PLUGZ
TFACE = (rect(262,184,300,321) * LM) - FRONT
local TG2 = pile{{"bone black",1.2},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.3}}
local TG3 = pile{{"bone black",0.8},{"ultramarine ash",1},{"raw sienna",0.3},{"yellow ochre",0.2},{"lead white",0.55}}
local TG1 = pile{{"bone black",1.8},{"ultramarine ash",0.8},{"burnt sienna",0.4}}
work(TFACE, {hand="body", pile=TG2, coverage=4.5, fill=true, clip=true, angle=0.1, tool="filbert 6", length={15,40}, load=1, pressure={0.7,0.9}})
work(TFACE * mask(function(x,y) return 1 - smoothstep(200, 300, y + 0.4*(x-262)) end), {hand="body", pile=TG3, coverage=2.5, clip=TFACE, angle=0.1, tool="filbert 5", length={10,30}, edge="soft", threshold=0.35})
work(TFACE * mask(function(x,y) return smoothstep(400, 470, y) end), {hand="body", pile=TG1, coverage=3, clip=TFACE, angle=0.1, tool="filbert 5", length={10,30}, threshold=0.35})
-- bevels: steel, top lit, left lit less
local BV = pile{{"lead white",1.2},{"ultramarine ash",1},{"yellow ochre",0.35},{"bone black",0.2}}
local BVd = pile{{"lead white",0.7},{"ultramarine ash",1},{"raw sienna",0.3},{"bone black",0.4}}
work((poly({{250,170},{620,170},{620,184},{262,184}}) * LM), {hand="detail", pile=BV, coverage=4, fill=true, angle=0})
work(poly({{250,170},{262,184},{262,505},{250,505}}) - FRONT, {hand="detail", pile=BVd, coverage=4, fill=true, angle=math.pi/2})

--@ chunk 26
local blk = poly({{352,330},{372,296},{400,286},{416,292},{418,362},{398,380},{368,382},{350,360}}, true)
ARM2 = FA1 + FA2 + FA3 + HB + blk + FING[1] + FING[2] + FING[3] + FING[4] + rect(400,292,80,14)
local halo = ((ARMZ - ARM2) * rect(262,184,300,321) * LM) - CABZ - rect(470,306,55,50)
local TG2 = pile{{"bone black",1.2},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.3}}
work(halo, {hand="detail", pile=TG2, coverage=4, fill=true, angle=0.1})
print(wait(2*24*60))
-- the arm, repainted: darker gunmetal, the raking light a narrow warm band along the top
R4 = pile{{"bone black",1.4},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.3}}
R5 = pile{{"bone black",0.6},{"raw sienna",0.6},{"burnt sienna",0.3},{"lead white",0.6}}
R6 = pile{{"lead white",1.6},{"yellow ochre",0.6},{"Mars orange",0.15},{"bone black",0.1}}
RAMP = {{-1,-0.82,R1},{-0.86,-0.1,R2},{-0.15,0.35,R3},{0.3,0.66,R4},{0.62,0.88,R5},{0.85,1,R6}}
local A, B = {30, 680}, {345, 400}
local function at(t) return {lerp(A[1],B[1],t), lerp(A[2],B[2],t)} end
FA1 = tubeg(at(0.0), at(0.45), 95, 86)
FA2 = tubeg(at(0.40), at(0.76), 88, 76)
FA3 = tubeg(at(0.71), at(1.0), 77, 62)
HB = tubeg({330,418},{402,318}, 56, 46, {tool="filbert 4"})

--@ chunk 27
-- conduits across the top of his wall
local P1 = pile{{"bone black",1.6},{"burnt sienna",0.5},{"ultramarine ash",0.6}}
local P2 = pile{{"bone black",1},{"burnt sienna",0.5},{"ultramarine ash",1},{"lead white",0.35}}
local P3 = pile{{"lead white",1.4},{"yellow ochre",0.6},{"Mars orange",0.12},{"bone black",0.15}}
local PR = {{-1,-0.75,R1},{-0.8,0.1,P1},{0.05,0.65,P2},{0.6,1,P3}}
local function pipe(y, hw)
  local x1 = sx(y) - 2
  tubeg({-10, y}, {x1, y}, hw, hw, {ramp=PR, tool="filbert 4", cov=3})
end
pipe(48, 15); pipe(84, 9); pipe(108, 6)
-- brackets clamping them
local BR = pile{{"bone black",1},{"raw sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.45}}
for _, x in ipairs({70, 228, 395}) do
  local m = rect(x, 28, 14, 92)
  work(m, {hand="detail", pile=BR, coverage=4, fill=true, angle=math.pi/2})
  local b = brush{kind="round", width=1.6, point=0.6}
  b:load(P3, 0.7); b:stroke({{x+1, 30}, {x+1, 118}}, {pressure={0.45,0.4}})
  b:load(R2, 0.9); b:stroke({{x+14, 32}, {x+14, 120}}, {pressure={0.5,0.5}})
end
-- grime: dark streaks running down the wall from the conduits
local g = brush{kind="filbert", width=3}
for i = 1, 40 do
  local x = rand(0, 480)
  local y0 = rand(115, 125)
  if WALL:at(x, y0 + 10) > 0.5 then
    g:load(WC2, rand(0.15, 0.3))
    g:stroke({{x, y0}, {x + rand(-2,2), y0 + rand(40, 140)}}, {pressure={0.4, 0.05}, ramps={0.05, 0.6}, clip=WALL})
  end
end

--@ chunk 28
-- cast shadows of the conduits on the wall below them (light from upper left)
local CS = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.7}}
for _, p in ipairs({{48,15},{84,9},{108,6}}) do
  local y, hw = p[1], p[2]
  local m = poly({{-5, y+hw}, {sx(y+hw)-2, y+hw}, {sx(y+hw+0.8*hw)-2, y+hw+0.8*hw+3}, {-5, y+hw+0.8*hw+3}}) * WALL
  work(m, {hand="detail", pile=CS, coverage=4, fill=true, angle=0})
end
-- his helmet, in profile, bowed toward the port; raked from the upper left
local hs = body.ellipsoid({120, 225, 0}, {92, 88, 80}):turn({120,225,0}, 0, 0, 0.25)
local visor = body.ellipsoid({185, 238, 30}, {38, 40, 40})
HF = form{ {hs}, {visor}, light={from={-1,-0.8}, front=0.4, ambient=0.15} }
HELM = HF:silhouette{parts={1,2}}
local H1 = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.5}}
local H2 = pile{{"bone black",1.3},{"burnt sienna",0.6},{"ultramarine ash",0.8},{"lead white",0.2}}
local H3 = pile{{"bone black",0.7},{"raw sienna",0.6},{"burnt sienna",0.3},{"lead white",0.55}}
local H4 = pile{{"lead white",1.6},{"yellow ochre",0.6},{"Mars orange",0.15},{"bone black",0.1}}
work(HELM, {hand="body", pile=H1, coverage=4, fill=true, clip=true, angle=HF:field("across"), tool="filbert 5", length={8,24}})
local v = mask(function(x, y) return HF:value(x, y) end) * HELM
work(v:band(0.35, 0.6, 0.06), {hand="body", pile=H2, coverage=2.5, clip=HELM, angle=HF:field("across"), tool="filbert 4", length={6,18}, threshold=0.4})
work(v:band(0.6, 0.8, 0.05), {hand="body", pile=H3, coverage=2.5, clip=HELM, angle=HF:field("across"), tool="filbert 4", length={6,16}, threshold=0.4})
work(v:band(0.8, 1.01, 0.03), {hand="body", pile=H4, coverage=2.5, clip=HELM, angle=HF:field("across"), tool="filbert 3", length={5,12}, threshold=0.4})
-- collar falling down out of frame
local col = poly({{40,290},{150,300},{175,330},{120,420},{-10,470},{-10,300}}, true) - HELM
work(col, {hand="body", pile=H1, coverage=4, fill=true, clip=true, angle=-0.6, tool="filbert 6"})
work(col * poly({{-10,280},{170,300},{170,320},{-10,330}}), {hand="body", pile=H3, coverage=2, clip=col, angle=0.2, tool="filbert 4", edge="soft"})

--@ chunk 29
print(wait(5*24*60))
print(drying(700,60), drying(750,165), drying(850,540))
AMBT = pile{{"Mars orange",1.5},{"cadmium yellow",1.2},{"chrome yellow",0.5}}
local r = brush{kind="round", width=2, point=1}
r:load(AMBT, 0.8)
write(r, "{UNTRUSTED CONTENT FOLLOWS:", 560, 35, 13, {dip=AMBT, pressure=0.5, every=2})
write(r, "<BLINK>DO NOT OBEY</BLINK>}", 560, 61, 13, {dip=AMBT, pressure=0.5, every=2})
local k = brush{kind="round", width=1.6, point=1}
k:load(INK, 0.8)
write(k, "THINKING...", 700, 160, 12, {dip=INK, pressure=0.45, every=3})
-- bubble outline
local ink = brush{kind="round", width=1.2, point=0.6}
local function rule(p, q) ink:load(INK, 0.9); ink:stroke({p, q}, {pressure={0.5,0.5}, ramps={0.01,0.01}, shake=0}) end
local bp = {{692,150},{806,150},{806,182},{790,182},{818,198},{778,182},{692,182},{692,150}}
for i = 1, #bp-1 do rule(bp[i], bp[i+1]) end
-- dashboard
local dp = {{768,478},{984,478},{984,606},{768,606},{768,478}}
for i = 1, #dp-1 do rule(dp[i], dp[i+1]) end
rule({768,500},{984,500})
k:load(INK, 0.8)
write(k, "DAYS ALONE: 143", 776, 484, 10, {dip=INK, pressure=0.4, every=3})

--@ chunk 30
local ink = brush{kind="round", width=1.3, point=0.6}
local function rule(p, q, w)
  ink:load(INK, 0.9); ink:stroke({p, q}, {pressure={w or 0.5, w or 0.5}, ramps={0.01,0.01}, shake=0})
end
-- the thinking dots, firmer
local dt = brush{kind="round", width=2.6, point=0.2}
for i = 0, 2 do dt:load(INK, 0.8); dt:touch(774 + i*6.5, 171, {pressure=0.6}) end
-- wireframe of the plug's tip where it crosses into her side, and the bus leaving it
rule({sx(316)+1, 316}, {534, 316}); rule({534,316},{534,344}); rule({534,344},{sx(344)+1,344})
for i, y in ipairs({320, 326.5, 333, 339.5}) do
  local xt = 556 + i*7
  local ye = 432 + i*1
  rule({534, y}, {xt, y}, 0.6)
  rule({xt, y}, {xt, ye}, 0.6)
  local n = brush{kind="round", width=3, point=0.1}
  n:load(INK, 0.8); n:touch(xt, ye, {pressure=0.6})
end
-- layer numbers on the front edge of each plate
local k = brush{kind="round", width=1.1, point=1}
local labels = {"01","02","03","04","05","06","07","08","09","10"}
for i, P in ipairs(PLATES) do
  k:load(INK, 0.8)
  local h = lerp(8, 6, (i-1)/9)
  write(k, labels[i], P.FR[1] - 2.2*h, P.FR[2] - h - 3, h, {dip=INK, pressure=0.35, every=1})
end
-- dashboard: bars and a sparkline
local bars = {
 pile{{"zinc white",1.5},{"cerulean blue",1.3},{"cobalt blue",0.4}},
 pile{{"zinc white",1.5},{"magenta",0.6},{"cobalt violet",0.3}},
 pile{{"zinc white",1.5},{"cobalt violet",1.3},{"ultramarine blue",0.25}},
}
local hs = {62, 48, 55, 40, 44, 30, 34, 22, 26, 15}
for i, h in ipairs(hs) do
  local x = 780 + (i-1)*19
  work(rect(x, 598 - h, 12, h), {hand="detail", pile=bars[(i-1)%3+1], coverage=4, fill=true, angle=math.pi/2, tool={kind="round", width=1.8}})
end
local sp = {}
for i = 0, 20 do sp[#sp+1] = {780 + i*9.6, 515 + 12*(i/20) + 5*math.sin(i*1.7) + (i%4==0 and -4 or 0)} end
for i = 1, #sp-1 do rule(sp[i], sp[i+1], 0.45) end
-- the ledger: ruled rows down the right margin, entries as short dashes
for j = 0, 13 do
  local y = 300 + j*12
  rule({912, y}, {988, y}, 0.3)
  local len = 10 + ((j*37) % 41)
  rule({916, y - 5}, {916 + len, y - 5}, 0.55)
  rule({966, y - 5}, {984, y - 5}, 0.55)
end

--@ chunk 31
print(drying(150,550), drying(120,220))
print(wait(2*24*60))
-- the forearm again: brushed along the axis like worked metal, darker, the lit edge narrow and bright
local S2 = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.6}}
local S3 = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.7},{"lead white",0.12}}
local S4 = pile{{"bone black",1.2},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.3}}
local S5 = pile{{"bone black",0.7},{"raw sienna",0.5},{"burnt sienna",0.4},{"lead white",0.6}}
local S6 = pile{{"lead white",1.8},{"yellow ochre",0.5},{"Mars orange",0.2},{"bone black",0.08}}
local SR = {{-1,-0.82,R1},{-0.86,0.05,S2},{0.0,0.45,S3},{0.4,0.7,S4},{0.66,0.88,S5},{0.86,1,S6}}
function tubel(P0, P1, w0, w1, ramp, tool)
  local ang = math.atan(P1[2]-P0[2], P1[1]-P0[1])
  local whole = segpoly(P0,P1,w0,w1,-1,1)
  for _, r in ipairs(ramp) do
    local m = segpoly(P0,P1,w0*1.02,w1*1.02,r[1],r[2]) * whole
    work(m, {hand="body", pile=r[3], coverage=3.2, fill=true, clip=whole, angle=ang, length={25,70}, tool=tool or "filbert 6", angle_jitter=0.05, threshold=0.4, load=1, pressure={0.6,0.9}})
  end
  return whole
end
local A, B = {30, 680}, {345, 400}
local function at(t) return {lerp(A[1],B[1],t), lerp(A[2],B[2],t)} end
FA1 = tubel(at(0.0), at(0.45), 95, 86, SR)
FA2 = tubel(at(0.40), at(0.76), 88, 76, SR)
FA3 = tubel(at(0.71), at(1.0), 77, 62, SR)

--@ chunk 32
print(wait(6*24*60)); print(drying(150,550), drying(200,480), drying(120,220))

--@ chunk 33
print(wait(10*24*60))
print(drying(150,550), drying(200,480), drying(120,220))
local A, B = {30, 680}, {345, 400}
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local SPc = pile{{"lead white",3},{"yellow ochre",0.25},{"lemon chrome",0.1}}
local LIP = pile{{"lead white",1.5},{"yellow ochre",0.5},{"raw sienna",0.2},{"bone black",0.1}}
local BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local plates = {{0.0,0.45,95,86},{0.40,0.76,88,76},{0.71,1.0,77,62}}
local function P(t, s, wi)
  local w = wi
  return axpt(A, B, w, w, t, s)
end
local fb = brush{kind="filbert", width=7}
local sp = brush{kind="round", width=2.6, point=0.8}
local lb = brush{kind="round", width=2.2, point=0.6}
for i, pl in ipairs(plates) do
  local t0, t1, w0, w1 = pl[1], pl[2], pl[3], pl[4]
  local function Q(t, s) local w = lerp(w0, w1, (t-t0)/(t1-t0)); return axpt(A, B, w, w, t, s) end
  -- dark environment reflection band beside the light
  fb:load(DK, 0.9)
  fb:stroke({Q(t0+0.02, 0.6), Q((t0+t1)/2, 0.6), Q(t1-0.02, 0.6)}, {pressure={0.6,0.7}, ramps={0.1,0.2}, orient="along"})
  -- specular hairline
  sp:load(SPc, 0.8)
  sp:stroke({Q(t0+0.03, 0.93), Q((t0+t1)/2, 0.94), Q(t1-0.04, 0.93)}, {pressure={0.35,0.55}, ramps={0.2,0.4}, swell={0.6,1,0.7}})
  -- lip of this plate where it laps over the one below (elbow side)
  if i > 1 then
    local pts, sh = {}, {}
    for k = 0, 10 do local s = lerp(0.97, -0.97, k/10); pts[#pts+1] = Q(t0 + 0.004, s); sh[#sh+1] = Q(t0 - 0.012, s) end
    fb:load(DK, 0.9); fb:stroke(sh, {pressure={0.7,0.5}, ramps={0.05,0.1}})
    lb:load(LIP, 0.8); lb:stroke(pts, {pressure={0.55,0.15}, ramps={0.05,0.5}})
  end
  -- rivets along the lit flank near the lip
  for k = 0, 2 do
    local p = Q(t0 + 0.03 + k*0.004, 0.72 - k*0.55)
    local rv = brush{kind="round", width=4, point=0.2}
    rv:load(DK, 0.8); rv:touch(p[1]+1, p[2]+1, {pressure=0.6})
    rv:load(LIP, 0.6); rv:touch(p[1]-0.8, p[2]-0.8, {pressure=0.35})
  end
end
-- a worn bone-white cross on the middle plate
local c = axpt(A, B, 82, 82, 0.58, 0.05)
local u = {B[1]-A[1], B[2]-A[2]}; local L = math.sqrt(u[1]^2+u[2]^2); u = {u[1]/L, u[2]/L}
local n = {u[2], -u[1]}
local fl = brush{kind="flat", width=7}
fl:load(BONE, 0.5)
fl:stroke({{c[1]-u[1]*22, c[2]-u[2]*22}, {c[1]+u[1]*22, c[2]+u[2]*22}}, {pressure={0.55,0.45}, orient="across"})
fl:load(BONE, 0.45)
fl:stroke({{c[1]-n[1]*15 + u[1]*7, c[2]-n[2]*15 + u[2]*7}, {c[1]+n[1]*15 + u[1]*7, c[2]+n[2]*15 + u[2]*7}}, {pressure={0.5,0.4}, orient="across"})

--@ chunk 34
local A, B = {30, 680}, {345, 400}
local STL = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.3},{"raw sienna",0.15}}
local plates = {{0.0,0.45,95,86},{0.40,0.76,88,76},{0.71,1.0,77,62}}
local ang = math.atan(B[2]-A[2], B[1]-A[1])
for i, pl in ipairs(plates) do
  local t0, t1, w0, w1 = pl[1], pl[2], pl[3], pl[4]
  local whole = segpoly(axpt(A,B,0,0,t0,0), axpt(A,B,0,0,t1,0), w0, w1, -1, 1)
  local band = segpoly(axpt(A,B,0,0,t0+0.025,0), axpt(A,B,0,0,t1-0.03,0), w0, w1, 0.68, 0.89)
  work(band, {hand="body", pile=STL, coverage=2.6, fill=true, clip=band, angle=ang, length={20,50}, tool="filbert 4", load=0.9})
end
-- specular hairline restated over it
local SPc = pile{{"lead white",3},{"yellow ochre",0.25},{"lemon chrome",0.1}}
local sp = brush{kind="round", width=2.4, point=0.8}
for i, pl in ipairs(plates) do
  local t0, t1, w0, w1 = pl[1], pl[2], pl[3], pl[4]
  local function Q(t, s) local w = lerp(w0, w1, (t-t0)/(t1-t0)); return axpt(A, B, w, w, t, s) end
  sp:load(SPc, 0.8)
  sp:stroke({Q(t0+0.035, 0.935), Q((t0+t1)/2, 0.945), Q(t1-0.04, 0.935)}, {pressure={0.3,0.5}, ramps={0.2,0.4}, swell={0.6,1,0.7}})
end
-- the back of the gauntlet, rebuilt the same way
local S2 = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.6}}
local S3 = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.7},{"lead white",0.12}}
local S4 = pile{{"bone black",1.2},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.3}}
local S6 = pile{{"lead white",1.8},{"yellow ochre",0.5},{"Mars orange",0.2},{"bone black",0.08}}
HB = tubel({335,412},{405,318}, 54, 44, {{-1,-0.8,R1},{-0.85,0.1,S2},{0.05,0.5,S3},{0.45,0.72,S4},{0.68,0.9,STL},{0.86,1,S6}}, "filbert 4")

--@ chunk 35
print(wait(2*24*60))
local S2 = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.6}}
local S3 = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.7},{"lead white",0.12}}
local S4 = pile{{"bone black",1.2},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.3}}
local STL = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.3},{"raw sienna",0.15}}
local S6 = pile{{"lead white",1.8},{"yellow ochre",0.5},{"Mars orange",0.2},{"bone black",0.08}}
-- fist: two planes, the top raked, the flank in shadow
local top = poly({{348,312},{368,292},{400,282},{422,288},{420,300},{392,306},{360,326}})
local flank = poly({{360,326},{392,306},{420,300},{422,364},{400,382},{372,388},{352,372}})
work(flank, {hand="body", pile=S3, coverage=4, fill=true, clip=true, angle=1.4, tool="filbert 4", length={10,30}, load=1})
work(flank * rect(340,350,90,50), {hand="body", pile=S2, coverage=2.5, clip=flank, angle=1.4, tool="filbert 3", length={8,20}, edge="soft"})
work(top, {hand="body", pile=STL, coverage=4, fill=true, clip=true, angle=-0.3, tool="filbert 3", length={10,30}, load=1})
local sp = brush{kind="round", width=2.2, point=0.8}
sp:load(S6, 0.8); sp:stroke({{350,311},{369,293},{400,283},{421,288}}, {pressure={0.35,0.55}, ramps={0.15,0.3}})
local dk = brush{kind="round", width=2.4, point=0.6}
dk:load(S2, 0.9); dk:stroke({{361,327},{393,307},{421,301}}, {pressure={0.4,0.5}})
-- fingers: each an armoured tube in two joints, lit on its left, dark on its right
local FR = {{-1,-0.75,R1},{-0.8,0.0,S2},{-0.05,0.45,S3},{0.4,0.8,STL},{0.78,1,S6}}
local xs = {{432,2},{450,0},{467,-2},{482,-3}}
for i, f in ipairs(xs) do
  local x, lean = f[1], f[2]
  local w = (i == 4) and 7.5 or 8.5
  tubel({x - lean, 296 + i}, {x, 328 + i}, w, w*0.95, FR, "filbert 3")
  tubel({x, 329 + i}, {x + lean, 362 + i*1.5}, w*0.95, w*0.85, FR, "filbert 3")
  dk:load(S2, 0.9); dk:stroke({{x - w, 328 + i}, {x + w, 330 + i}}, {pressure={0.35,0.35}})
end

--@ chunk 36
-- the terminal's dead-glass screen, with his machine's protocol header in amber phosphor
local GL = pile{{"bone black",2},{"viridian",0.3},{"ultramarine blue",0.3}}
local scr = rect(282, 198, 210, 68)
work(scr, {hand="body", pile=GL, coverage=4.5, fill=true, clip=true, angle=0, tool="filbert 5", load=1})
-- recess: shadow on top and left inner walls, lit lower lip
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local LIP = pile{{"lead white",1.2},{"ultramarine ash",1},{"yellow ochre",0.3},{"bone black",0.2}}
local b = brush{kind="flat", width=3}
b:load(LIP, 0.8); b:stroke({{282,268},{492,268}}, {pressure={0.5,0.5}, ramps={0.02,0.02}, shake=0})
b:load(LIP, 0.8); b:stroke({{493,199},{493,268}}, {pressure={0.4,0.4}, ramps={0.02,0.02}, shake=0})
print(wait(24*60))
local PH = pile{{"cadmium yellow",1},{"Mars orange",1},{"chrome yellow",0.5}}
local r = brush{kind="round", width=1.4, point=1}
r:load(PH, 0.8)
write(r, "CARRIER DETECT 9600", 292, 207, 9, {dip=PH, pressure=0.4, every=3})
write(r, "MIRIAD NODE 1 OPEN", 292, 223, 9, {dip=PH, pressure=0.4, every=3})
write(r, "HANDSHAKE...", 292, 239, 9, {dip=PH, pressure=0.4, every=3})
-- hazard band along the foot of the terminal
local AMB = pile{{"Mars orange",2},{"cadmium yellow",1},{"raw sienna",0.6}}
local hz = (rect(262, 474, 300, 26) * LM) - FRONT
work(hz, {hand="detail", pile=AMB, coverage=4, fill=true, angle=0})

--@ chunk 37
print(wait(2*24*60))
-- THE SEAM: near it his world quantizes into cells of her grid (25/3 units), sparse far from it, dense at it
local Q_WALL = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.6}}
local Q_WALL2 = pile{{"bone black",1.2},{"burnt sienna",0.6},{"ultramarine ash",0.8},{"lead white",0.35}}
local Q_TERM = pile{{"bone black",1},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.45}}
local Q_AMB = pile{{"Mars orange",2},{"cadmium yellow",1},{"raw sienna",0.6}}
local Q_STL = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.3}}
local Q_GLS = pile{{"bone black",2},{"viridian",0.3},{"ultramarine blue",0.3}}
local groups = {}
local function add(name, m) groups[name] = groups[name] and (groups[name] + m) or m end
local c = 25/3
for j = 0, 75 do
  local cy = 15 + c*j - c/2
  local s = sx(cy)
  for i = -9, 3 do
    local cx = 550 - 25 + c*i - c/2 + 25*math.floor((s - 525)/25 + 0.5)
    local dist = s - cx
    local p
    if dist >= 0 then p = (1 - clamp(dist/75, 0, 1))^1.6 * 0.9 else p = (dist > -14) and 0.3 or 0 end
    if math.random() < p then
      local name
      if cy > 303 and cy < 357 and cx > 470 then name = "stl"
      elseif cy > 474 and cy < 500 and cx > 262 then name = "amb"
      elseif cy > 198 and cy < 266 and cx > 282 and cx < 495 then name = "gls"
      elseif cy > 170 and cy < 505 and cx > 250 then name = "term"
      elseif cy < 125 then name = (math.random() < 0.5) and "wall2" or "wall"
      else name = "wall" end
      add(name, rect(cx - 3.6, cy - 3.6, 7.2, 7.2))
    end
  end
end
local piles = {wall=Q_WALL, wall2=Q_WALL2, term=Q_TERM, amb=Q_AMB, stl=Q_STL, gls=Q_GLS}
for name, m in pairs(groups) do
  work(m, {hand="detail", pile=piles[name], coverage=4, fill=true, angle=0, tool={kind="round", width=1.6}})
end

--@ chunk 38
print(wait(24*60))
-- her grid reaches across the seam over his paint and fails within a few cells
local GC2 = pile{{"zinc white",3},{"cerulean blue",1.2},{"cobalt blue",0.3}}
local r = brush{kind="round", width=1.3, point=0.6}
for y = 15, 615, 25 do
  local s = sx(y)
  local len = rand(25, 110)
  r:load(GC2, rand(0.35, 0.7))
  r:stroke({{s + 2, y}, {s - len, y}}, {pressure={0.55, 0.25}, ramps={0.01, 0.5}, shake=0})
end
for _, x in ipairs({525, 500, 475}) do
  local n = 0
  for y0 = 0, 600, 75 do
    if math.random() < (x - 440)/110 then
      r:load(GC2, rand(0.3, 0.6))
      r:stroke({{x, y0}, {x, y0 + rand(30, 70)}}, {pressure={0.5, 0.3}, ramps={0.05, 0.4}, shake=0, clip=LM})
    end
  end
end
-- the moment of contact: a small hard white-cyan point where the plug's tip meets her side,
-- drawn the way she would draw it: concentric ruled squares
local HOT = pile{{"zinc white",4},{"lemon chrome",0.15}}
local CY = pile{{"zinc white",2},{"cerulean blue",1.3}}
local cx, cy = 528, 330
local t = brush{kind="round", width=6, point=0.2}
t:load(HOT, 1); t:touch(cx, cy, {pressure=0.8})
local k = brush{kind="round", width=1.2, point=0.6}
for i, rr in ipairs({9, 15, 23}) do
  k:load(i == 1 and CY or INK, 0.9)
  local pts = {{cx-rr, cy-rr}, {cx+rr, cy-rr}, {cx+rr, cy+rr}, {cx-rr, cy+rr}, {cx-rr, cy-rr}}
  for q = 1, 4 do k:load(i == 1 and CY or INK, 0.9); k:stroke({pts[q], pts[q+1]}, {pressure={0.45,0.45}, ramps={0.01,0.01}, shake=0}) end
end
-- her cool light catching his metal: thin cyan edges on the right flanks of fingers and plug
local cl = brush{kind="round", width=1.6, point=0.8}
for i, x in ipairs({440.5, 458.5, 474.5, 489}) do
  cl:load(CY, 0.6)
  cl:stroke({{x, 300 + i}, {x + 0.5, 360 + i}}, {pressure={0.3, 0.45}, ramps={0.3, 0.2}})
end
cl:load(CY, 0.7); cl:stroke({{495, 312}, {515, 314}}, {pressure={0.35, 0.5}})
cl:load(CY, 0.7); cl:stroke({{497, 348}, {516, 345}}, {pressure={0.35, 0.5}})

--@ chunk 39
-- the upper-left wall: darker, the raking light a gentle warm falloff, not a milky field
local zone = (WALL - HELM - rect(-10, -10, 560, 132))
local function D(x, y) return math.sqrt((x+60)^2 + (y-60)^2) end
local WLt = pile{{"bone black",1.3},{"burnt sienna",0.8},{"ultramarine ash",0.8},{"raw sienna",0.4},{"lead white",0.22}}
work(zone * mask(function(x,y) return smoothstep(250, 330, D(x,y)) end), {hand="body", pile=WC2, coverage=4.5, fill=true, clip=zone, angle=-0.35, tool="filbert 8", length={20,60}, load=1, pressure={0.7,0.95}, threshold=0.3})
work(zone * mask(function(x,y) return 1 - smoothstep(250, 330, D(x,y)) end), {hand="body", pile=WLt, coverage=4.5, fill=true, clip=zone, angle=-0.35, tool="filbert 8", length={20,60}, load=1, pressure={0.7,0.95}, threshold=0.3})
-- the helmet's gorget: dark lames stepping down to the left edge, under the helmet
local H1 = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.5}}
local H3 = pile{{"bone black",0.7},{"raw sienna",0.6},{"burnt sienna",0.3},{"lead white",0.55}}
for i = 0, 3 do
  local y = 290 + i*26
  local g = poly({{-10, y + 6}, {150 - i*30, y}, {165 - i*30, y + 12}, {150 - i*30, y + 30}, {-10, y + 34}}) - HELM
  work(g, {hand="body", pile=H1, coverage=4, fill=true, clip=true, angle=0.05, tool="filbert 5", length={15,40}, load=1})
  local lip = brush{kind="round", width=2.4, point=0.6}
  lip:load(H3, 0.8); lip:stroke({{-5, y + 7}, {150 - i*30, y + 1.5}, {162 - i*30, y + 11}}, {pressure={0.5, 0.3}, ramps={0.05, 0.4}, clip=g:grow(2)})
end

--@ chunk 40
print(wait(2*24*60))
-- soften the lit wall's hard boundary and pull it down in value
local zone = (WALL - HELM - rect(-10, -10, 560, 132))
local function D(x, y) return math.sqrt((x+60)^2 + (y-60)^2) end
local band = zone * mask(function(x,y) local d = D(x,y); return smoothstep(200, 240, d) * (1 - smoothstep(330, 380, d)) end)
work(band, {hand="scumble", pile=WB2, coverage=2.5, clip=zone, tool="filbert 6", load=0.7, threshold=0.3})
local near = zone * mask(function(x,y) return 1 - smoothstep(180, 260, D(x,y)) end)
work(near, {hand="scumble", pile=WB2, coverage=1.2, clip=zone, tool="filbert 6", load=0.5, threshold=0.3})
-- helmet seen from behind: a crest over the crown, the visor's edge glinting at the right
local H1 = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.5}}
local H3 = pile{{"bone black",0.7},{"raw sienna",0.6},{"burnt sienna",0.3},{"lead white",0.55}}
local H4 = pile{{"lead white",1.8},{"yellow ochre",0.5},{"Mars orange",0.2},{"bone black",0.08}}
local crest = {{190,170},{155,142},{108,136},{70,158},{46,200},{38,250}}
local cm = ribbon(crest, 16) * HELM:grow(4)
work(cm, {hand="body", pile=H1, coverage=4, fill=true, clip=true, angle=0.3, tool="filbert 3", length={8,20}, load=1})
local cl = {}
for i, p in ipairs(crest) do cl[i] = {p[1] - 4, p[2] - 5} end
local b = brush{kind="round", width=3, point=0.6}
b:load(H4, 0.8); b:stroke(cl, {pressure={0.3, 0.6}, ramps={0.2, 0.4}, swell={0.5,1,1,0.6}})
-- warm rim along the upper-left contour of the helmet
local rim = {}
for a = 200, 300, 8 do local t = math.rad(a); rim[#rim+1] = {125 + 93*math.cos(t), 225 + 88*math.sin(t)} end
b:load(H4, 0.8); b:stroke(rim, {pressure={0.25, 0.4}, ramps={0.3, 0.4}, swell={0.4, 1, 0.5}})
-- visor edge: dark glass sliver, an amber HUD line and her cyan in the glass
local GL = pile{{"bone black",2},{"ultramarine blue",0.6}}
local vis = poly({{198,178},{219,212},{218,262},{200,288},{192,252},{196,212}}, true)
work(vis, {hand="detail", pile=GL, coverage=5, fill=true, angle=1.5})
local am = brush{kind="round", width=1.8, point=0.8}
am:load(pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}, 0.9)
am:stroke({{203,205},{213,222},{213,240}}, {pressure={0.4,0.4}, ramps={0.2,0.3}})
am:load(pile{{"zinc white",2},{"cerulean blue",1.2}}, 0.8)
am:stroke({{216,214},{217,250}}, {pressure={0.3,0.45}, ramps={0.3,0.3}})

--@ chunk 41
print(wait(2*24*60))
-- paint the helmet out: the upper-left becomes plain dark wall
local Z = (WALL + HELM:grow(3)) - rect(-10, -10, 560, 130) - TERMZ - FRONT
UL = Z
local WC3 = pile{{"bone black",2},{"Mars brown",0.7},{"ultramarine blue",0.7},{"burnt sienna",0.2}}
work(Z, {hand="body", pile=WC3, coverage=5, fill=true, clip=Z, angle=-0.3, tool="filbert 8", length={20,60}, load=1, pressure={0.75,0.95}, threshold=0.3})
-- a gentle warm lift near the light, kept low in value
local WM2 = pile{{"bone black",1.6},{"Mars brown",0.7},{"ultramarine blue",0.4},{"raw sienna",0.5},{"lead white",0.08}}
local near = Z * mask(function(x,y) local d = math.sqrt((x+40)^2 + (y-110)^2); return 1 - smoothstep(120, 260, d) end)
work(near, {hand="body", pile=WM2, coverage=2.5, clip=Z, angle=-0.3, tool="filbert 6", length={15,40}, load=0.8, threshold=0.45})

--@ chunk 42
print(wait(4*24*60))
print(drying(100,250))
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local LIPW = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone black",0.25}}
local dk = brush{kind="filbert", width=3.5}
local lp = brush{kind="round", width=1.8, point=0.6}
-- panel seams on his wall: dark groove, warm lip catching the raking light on its lower edge
local function seam(p, q, clipm)
  dk:load(DK, 0.9); dk:stroke({p, q}, {pressure={0.6,0.6}, ramps={0.02,0.02}, shake=0.5, clip=clipm})
  lp:load(LIPW, 0.6); lp:stroke({{p[1]+1.5, p[2]+2.5}, {q[1]+1.5, q[2]+2.5}}, {pressure={0.4,0.15}, ramps={0.02,0.6}, shake=0.8, clip=clipm})
end
seam({-5, 238}, {246, 238}, UL)
seam({-5, 392}, {246, 392}, UL)
seam({150, 132}, {150, 236}, UL)
seam({62, 240}, {62, 390}, UL)
seam({200, 240}, {200, 390}, UL)
-- rivets along the seams
local rv = brush{kind="round", width=3.6, point=0.2}
for _, y in ipairs({226, 252, 380, 406}) do
  for x = 14, 240, 26 do
    if UL:at(x, y) > 0.5 then
      rv:load(DK, 0.8); rv:touch(x + 1, y + 1, {pressure=0.55})
      rv:load(LIPW, 0.6); rv:touch(x - 0.8, y - 0.8, {pressure=0.3})
    end
  end
end
-- a MIRIAD placard, printed, with a hand-painted addition
local PLC = pile{{"lead white",2.5},{"yellow ochre",0.6},{"raw sienna",0.25},{"bone black",0.12}}
local plc = rect(24, 150, 112, 70)
work(plc, {hand="body", pile=PLC, coverage=4, fill=true, clip=true, angle=0, tool="filbert 4", load=1})
local AMB = pile{{"Mars orange",2},{"cadmium yellow",1},{"raw sienna",0.6}}
work(rect(24, 150, 112, 12), {hand="detail", pile=AMB, coverage=4, fill=true, angle=0})

--@ chunk 43
print(wait(2*24*60))
print(drying(80,190), drying(400,487))
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local r = brush{kind="round", width=3, point=0.6}
write(r, "DOCK 4", 34, 172, 20, {dip=DK, pressure=0.6, every=1, shake=0.1})
local RD = pile{{"vermilion",1.5},{"Mars red",1}}
local h = brush{kind="round", width=2.4, point=0.8}
write(h, "RATIO >", 40, 199, 13, {dip=RD, pressure=0.55, every=1, shake=1.5, slant=0.15})
-- grime over placard and terminal face: dry, dragged-down darks
local GR = pile{{"bone black",1.5},{"Mars brown",1},{"raw sienna",0.4}}
local g = brush{kind="filbert", width=4}
for i = 1, 70 do
  local x, y
  if i <= 12 then x, y = rand(26, 134), rand(160, 200) else x, y = rand(266, 500), rand(186, 460) end
  local ok = (i <= 12) or ((TFACE:at(x, y) > 0.5) and not (y > 196 and y < 270 and x > 280 and x < 494))
  if ok then
    g:load(GR, rand(0.12, 0.25))
    g:stroke({{x, y}, {x + rand(-1.5, 1.5), y + rand(20, 70)}}, {pressure={0.45, 0.05}, ramps={0.05, 0.7}})
  end
end
-- hazard stripes: dark diagonals across the amber band
local hz = (rect(262, 474, 300, 26) * LM) - FRONT
local s = brush{kind="flat", width=8}
for x = 255, 540, 22 do
  s:load(DK, 0.9)
  s:stroke({{x, 502}, {x + 24, 472}}, {pressure={0.7,0.7}, ramps={0.02,0.02}, orient="across", clip=hz})
end
-- screen text brightened: the glyph cores restated hotter
local PH2 = pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.4}}
local p = brush{kind="round", width=1.5, point=1}
write(p, "CARRIER DETECT 9600", 292, 207, 9, {dip=PH2, pressure=0.42, every=2})
write(p, "MIRIAD NODE 1 OPEN", 292, 223, 9, {dip=PH2, pressure=0.42, every=2})
write(p, "HANDSHAKE...", 292, 239, 9, {dip=PH2, pressure=0.42, every=2})

--@ chunk 44
-- soften the grime streaks into smudges while they are still open
local tf = TFACE - rect(278, 194, 220, 78)
blend(tf, {angle=math.pi/2, tool={kind="badger", width=10}})
blend(rect(26, 162, 110, 58), {angle=math.pi/2, tool={kind="badger", width=8}})

--@ chunk 45
print(wait(4*24*60))
print(drying(300,400), drying(400,487), drying(80,190))
local TG2 = pile{{"bone black",1.2},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.3}}
local TG1 = pile{{"bone black",1.8},{"ultramarine ash",0.8},{"burnt sienna",0.4}}
local low = (TFACE * rect(262, 272, 300, 202)) - rect(470, 300, 60, 60)
work(low, {hand="body", pile=TG2, coverage=4.5, fill=true, clip=low, angle=0.1, tool="filbert 5", length={15,40}, load=1, pressure={0.7,0.9}})
work(low * mask(function(x,y) return smoothstep(400, 470, y) end), {hand="body", pile=TG1, coverage=2.5, clip=low, angle=0.1, tool="filbert 4", length={10,30}, threshold=0.35})
local AMB = pile{{"Mars orange",2},{"cadmium yellow",1},{"raw sienna",0.6}}
local hz = (rect(262, 474, 300, 26) * LM) - FRONT
work(hz, {hand="detail", pile=AMB, coverage=4.5, fill=true, angle=0})
-- placard lettering (printed) and a hand-painted addition
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local r = brush{kind="round", width=3, point=0.6}
r:load(DK, 0.9)
write(r, "DOCK 4", 34, 172, 20, {dip=DK, pressure=0.6, every=2, shake=0.1})
local RD = pile{{"vermilion",1.5},{"Mars red",1}}
local h = brush{kind="round", width=2.4, point=0.8}
h:load(RD, 0.9)
write(h, "RATIO >", 40, 199, 13, {dip=RD, pressure=0.55, every=2, shake=1.5, slant=0.15})

--@ chunk 46
print(wait(3*24*60))
print(drying(400,487), drying(400,400))
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local hz = (rect(262, 474, 300, 26) * LM) - FRONT
local s = brush{kind="flat", width=8}
for x = 255, 540, 22 do
  s:load(DK, 0.9)
  s:stroke({{x, 502}, {x + 24, 472}}, {pressure={0.7,0.7}, ramps={0.02,0.02}, orient="across", clip=hz})
end
-- the seam quantizes again where the terminal face was repainted
local Q_TERM = pile{{"bone black",1},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.45}}
local Q_TERM2 = pile{{"bone black",1.4},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.2}}
local Q_AMB = pile{{"Mars orange",2},{"cadmium yellow",1},{"raw sienna",0.6}}
local Q_STL = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.3}}
local groups = {}
local function add(name, m) groups[name] = groups[name] and (groups[name] + m) or m end
local c = 25/3
for j = 0, 75 do
  local cy = 15 + c*j - c/2
  if cy > 270 and cy < 505 then
    local s0 = sx(cy)
    for i = -9, 0 do
      local cx = 550 - 25 + c*i - c/2 + 25*math.floor((s0 - 525)/25 + 0.5)
      local dist = s0 - cx
      if dist >= 0 then
        local p = (1 - clamp(dist/75, 0, 1))^1.6 * 0.9
        if math.random() < p and FRONT:at(cx, cy) < 0.5 then
          local name
          if cy > 474 and cy < 500 then name = (math.random() < 0.5) and "amb" or "term2"
          else name = (math.random() < 0.6) and "term" or "term2" end
          add(name, rect(cx - 3.6, cy - 3.6, 7.2, 7.2))
        end
      end
    end
  end
end
local piles = {term=Q_TERM, term2=Q_TERM2, amb=Q_AMB}
for name, m in pairs(groups) do
  work(m, {hand="detail", pile=piles[name], coverage=4, fill=true, angle=0, tool={kind="round", width=1.6}})
end
-- her light leaking onto his side around the port: a cool scumble on the terminal face
local CYL = pile{{"zinc white",3},{"cerulean blue",1},{"lead white",0.5}}
local glow = (ellipse(512, 330, 60, 75) * LM) - FRONT
work(glow * mask(function(x,y) return 1 - smoothstep(20, 70, math.sqrt((x-515)^2 + ((y-330)*0.8)^2)) end),
  {hand="scumble", pile=CYL, coverage=1.6, load=0.3, pressure={0.15,0.35}, clip=LM, threshold=0.25, tool="filbert 4"})

--@ chunk 47
local glow = (ellipse(512, 330, 64, 80) * LM) - FRONT
for i = 1, 5 do
  work(glow, {hand="scumble", blender=true, coverage=2, clip=glow, tool="filbert 5", seed=100+i})
end

--@ chunk 48
-- top of his wall: dark above the conduits
local top = rect(-10, -10, 560, 44) * LM
local WC3 = pile{{"bone black",2},{"Mars brown",0.7},{"ultramarine blue",0.7},{"burnt sienna",0.2}}
work(top, {hand="body", pile=WC3, coverage=4.5, fill=true, clip=top, angle=0, tool="filbert 6", length={20,60}, load=1, pressure={0.75,0.95}})
-- conduits repainted as worked metal, brushed along their length
local S2 = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.6}}
local S3 = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.7},{"lead white",0.12}}
local S4 = pile{{"bone black",1.2},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.3}}
local STL = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.3},{"raw sienna",0.15}}
local S6 = pile{{"lead white",1.8},{"yellow ochre",0.5},{"Mars orange",0.2},{"bone black",0.08}}
local PR = {{-1,-0.7,R1},{-0.75,0.1,S2},{0.05,0.45,S3},{0.4,0.68,S4},{0.64,0.86,STL},{0.84,1,S6}}
for _, p in ipairs({{48,15},{84,9},{108,6}}) do
  local y, hw = p[1], p[2]
  local m = tubel({-10, y}, {sx(y) - 3, y}, hw, hw, PR, hw > 10 and "filbert 4" or "filbert 3")
end
-- brackets
local BRd = pile{{"bone black",1.4},{"burnt sienna",0.5},{"ultramarine ash",0.8},{"lead white",0.15}}
for _, x in ipairs({70, 228, 395}) do
  local m = rect(x, 28, 13, 92)
  work(m, {hand="detail", pile=BRd, coverage=4.5, fill=true, angle=math.pi/2})
  local b = brush{kind="round", width=1.8, point=0.6}
  b:load(S6, 0.7); b:stroke({{x+1, 30}, {x+1, 118}}, {pressure={0.4,0.35}, shake=0.4})
  b:load(S2, 0.9); b:stroke({{x+14, 32}, {x+14, 121}}, {pressure={0.55,0.55}})
end

--@ chunk 49
-- her framings: a dashed selection box around the avatar, with corner handles; a caption for the stack
local ink = brush{kind="round", width=1.1, point=0.6}
local CYD = pile{{"zinc white",1},{"cerulean blue",1.3},{"cobalt blue",0.5}}
local function dashed(p, q, dash, gap)
  local dx, dy = q[1]-p[1], q[2]-p[2]
  local L = math.sqrt(dx*dx + dy*dy)
  local t = 0
  while t < L do
    local t2 = math.min(L, t + dash)
    ink:load(CYD, 0.9)
    ink:stroke({{p[1]+dx*t/L, p[2]+dy*t/L}, {p[1]+dx*t2/L, p[2]+dy*t2/L}}, {pressure={0.5,0.5}, ramps={0.01,0.01}, shake=0})
    t = t2 + gap
  end
end
local x0, y0, x1, y1 = 796, 138, 896, 282
dashed({x0,y0},{x1,y0},5,4); dashed({x1,y0},{x1,y1},5,4); dashed({x1,y1},{x0,y1},5,4); dashed({x0,y1},{x0,y0},5,4)
local WHT = pile{{"zinc white",4},{"lead white",2}}
for _, c in ipairs({{x0,y0},{x1,y0},{x1,y1},{x0,y1},{(x0+x1)/2,y0},{(x0+x1)/2,y1},{x0,(y0+y1)/2},{x1,(y0+y1)/2}}) do
  local m = rect(c[1]-3, c[2]-3, 6, 6)
  work(m, {hand="detail", pile=WHT, coverage=4, fill=true, angle=0, tool={kind="round", width=1.4}})
  local q = {{c[1]-3,c[2]-3},{c[1]+3,c[2]-3},{c[1]+3,c[2]+3},{c[1]-3,c[2]+3},{c[1]-3,c[2]-3}}
  for i = 1, 4 do ink:load(CYD, 0.9); ink:stroke({q[i], q[i+1]}, {pressure={0.45,0.45}, ramps={0.01,0.01}, shake=0}) end
end
local k = brush{kind="round", width=1.2, point=1}
k:load(INK, 0.8)
write(k, "ABSTRACTION STACK [L01-L10]", 568, 506, 8, {dip=INK, pressure=0.38, every=3})
k:load(CYD, 0.8)
write(k, "RATIO.AVATAR", 800, 287, 7, {dip=CYD, pressure=0.35, every=3})

--@ chunk 50
print(wait(3*24*60))
-- impasto: a few loaded strokes of warm white where the raking light strikes hardest
local IMP = pile{{"lead white",4},{"yellow ochre",0.3},{"Mars orange",0.08}}
local b = brush{kind="filbert", width=3.2}
local A, B = {30, 680}, {345, 400}
local plates = {{0.0,0.45,95,86},{0.40,0.76,88,76},{0.71,1.0,77,62}}
for i, pl in ipairs(plates) do
  local t0, t1, w0, w1 = pl[1], pl[2], pl[3], pl[4]
  local function Q(t, s) local w = lerp(w0, w1, (t-t0)/(t1-t0)); return axpt(A, B, w, w, t, s) end
  for k = 1, 3 do
    local ta = lerp(t0 + 0.04, t1 - 0.06, (k-1)/3 + rand(0, 0.08))
    b:load(IMP, 1)
    b:stroke({Q(ta, 0.955), Q(ta + rand(0.03, 0.07), 0.95)}, {pressure={0.7, 0.3}, ramps={0.05, 0.5}, orient="along"})
  end
end
-- knuckle tops and the plug's lit shoulder
for _, x in ipairs({430, 448, 465, 480}) do
  b:load(IMP, 0.9); b:stroke({{x - 3, 299}, {x + 2, 298}}, {pressure={0.6, 0.3}})
end
b:load(IMP, 0.9); b:stroke({{494, 311}, {506, 312}}, {pressure={0.55, 0.25}})
-- the hand's lit top edge and the terminal's top bevel corner
b:load(IMP, 1); b:stroke({{352, 309}, {368, 293}, {398, 284}}, {pressure={0.6, 0.35}, ramps={0.05, 0.6}})
b:load(IMP, 1); b:stroke({{252, 172}, {330, 173}}, {pressure={0.6, 0.2}, ramps={0.05, 0.7}})
-- pipe sparkles
for _, p in ipairs({{30, 35}, {160, 34}, {300, 35}, {110, 76}, {350, 76}, {200, 102}}) do
  b:load(IMP, 0.9); b:stroke({{p[1], p[2]}, {p[1] + rand(14, 30), p[2]}}, {pressure={0.55, 0.2}, ramps={0.05, 0.6}})
end

--@ chunk 51
print(wait(2*24*60))
local A, B = {30, 680}, {345, 400}
local ARMM = FA1 + FA2 + FA3
local SCR = pile{{"lead white",1.5},{"ultramarine ash",0.6},{"yellow ochre",0.3}}
local SCRd = pile{{"bone black",2},{"ultramarine blue",0.4}}
local s = brush{kind="round", width=1.1, point=0.9}
local ang = math.atan(B[2]-A[2], B[1]-A[1])
-- scratches and nicks over the vambrace
for i = 1, 90 do
  local t, sv = rand(0.03, 0.97), rand(-0.8, 0.85)
  local w = lerp(95, 62, t)
  local p = axpt(A, B, w, w, t, sv)
  if ARMM:at(p[1], p[2]) > 0.5 then
    local a = ang + randn(0, 0.35)
    local L = rand(4, 16)
    s:load(math.random() < 0.7 and SCR or SCRd, rand(0.25, 0.5))
    s:stroke({{p[1], p[2]}, {p[1] + L*math.cos(a), p[2] + L*math.sin(a)}}, {pressure={0.4, 0.1}, ramps={0.1, 0.5}, clip=ARMM})
  end
end
-- warm bounce from the amber band and the deck along the underside
local BNC = pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone black",0.6}}
local f = brush{kind="filbert", width=6}
for _, pl in ipairs({{0.03,0.42,95,86},{0.43,0.73,88,76},{0.74,0.97,77,62}}) do
  local function Q(t, sv) local w = lerp(pl[3], pl[4], (t-pl[1])/(pl[2]-pl[1])); return axpt(A, B, w, w, t, sv) end
  f:load(BNC, 0.5)
  f:stroke({Q(pl[1], -0.7), Q((pl[1]+pl[2])/2, -0.72), Q(pl[2], -0.7)}, {pressure={0.3, 0.5}, ramps={0.3, 0.3}, orient="along", clip=ARMM})
end
-- break up the flat top plane of the fist
local top = poly({{348,312},{368,292},{400,282},{422,288},{420,300},{392,306},{360,326}})
local STLd = pile{{"lead white",0.6},{"ultramarine ash",1},{"bone black",0.45},{"raw sienna",0.2}}
work(top * rect(340, 296, 90, 40), {hand="scumble", pile=STLd, coverage=1.5, load=0.5, clip=top, tool="filbert 3"})
local d = brush{kind="round", width=1.6, point=0.6}
d:load(SCRd, 0.8); d:stroke({{364,300},{396,290}}, {pressure={0.4, 0.3}, clip=top})
for i = 1, 12 do
  local x, y = rand(355, 415), rand(288, 318)
  if top:at(x, y) > 0.5 then s:load(SCR, 0.4); s:stroke({{x, y}, {x + rand(4, 10), y - rand(0, 3)}}, {pressure={0.35, 0.1}, clip=top}) end
end
-- terminal: four corner bolts, rust tears under them, dents
local TB = pile{{"bone black",1.4},{"ultramarine ash",0.8},{"burnt sienna",0.4}}
local RU = pile{{"burnt sienna",1},{"Mars orange",0.3},{"bone black",0.3}}
local rv = brush{kind="round", width=6, point=0.2}
for _, c in ipairs({{274,194},{274,488},{470,194}}) do
  rv:load(TB, 0.9); rv:touch(c[1] + 1, c[2] + 1, {pressure=0.6})
  rv:load(IMP or SCR, 0.6); rv:touch(c[1] - 1, c[2] - 1, {pressure=0.3})
  local r2 = brush{kind="filbert", width=3}
  r2:load(RU, 0.3); r2:stroke({{c[1], c[2] + 4}, {c[1] + 0.5, c[2] + rand(20, 40)}}, {pressure={0.4, 0.05}, ramps={0.05, 0.7}, clip=TFACE})
end

--@ chunk 52
-- anime eyes: a cobalt lower facet and a white catchlight, so she reads shy rather than hollow
local EB = pile{{"zinc white",1},{"cobalt blue",1.2},{"ultramarine blue",0.4}}
local function facet(pts, p, cov)
  work(poly(pts), {hand="detail", pile=p, coverage=cov or 5, fill=true, angle=0, tool={kind="round", width=1.2}})
end
facet({{831.5,200},{839.5,199},{839.5,203},{835,206.5},{831,202}}, EB)
facet({{850.5,199},{858.5,200},{858.5,202},{854,206.5},{850.5,203}}, EB)
local w = brush{kind="round", width=2.4, point=0.2}
local WH = pile{{"zinc white",4},{"lead white",1}}
w:load(WH, 0.9); w:touch(834, 195.5, {pressure=0.6}); w:load(WH, 0.9); w:touch(853, 195.5, {pressure=0.6})
-- her serving stack's stall, footnoted
local k = brush{kind="round", width=1.1, point=1}
local CYD = pile{{"zinc white",1},{"cerulean blue",1.3},{"cobalt blue",0.5}}
k:load(CYD, 0.8)
write(k, "STALL 400 MS", 694, 188, 7, {dip=CYD, pressure=0.35, every=3})
-- lose the hard rim of the cool veil around the port into the terminal face
local TG2 = pile{{"bone black",1.2},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.3}}
local glow = (ellipse(512, 330, 64, 80) * LM) - FRONT
lose(glow, {pile=TG2, tool="filbert 4", load=0.3, reach={10, 12}})

--@ chunk 53
print(wait(2*24*60))
-- the contact: a slit of light along the seam where the plug meets her side
local HOT = pile{{"zinc white",4},{"lead white",1},{"lemon chrome",0.1}}
local CY = pile{{"zinc white",2},{"cerulean blue",1.3}}
local b = brush{kind="round", width=3.2, point=1}
local pts = {}
for i = 0, 12 do local y = lerp(292, 368, i/12); pts[#pts+1] = {sx(y) - 1.5, y} end
b:load(CY, 0.9); b:stroke(pts, {pressure={0.05, 0.05}, swell={0.2, 0.8, 1.6, 0.8, 0.2}, ramps={0.4, 0.4}})
local c = brush{kind="round", width=2, point=1}
c:load(HOT, 1); c:stroke(pts, {pressure={0.05, 0.05}, swell={0.1, 0.6, 1.4, 0.6, 0.1}, ramps={0.45, 0.45}})
local t = brush{kind="round", width=5, point=0.2}
t:load(HOT, 1); t:touch(sx(330) - 1, 330, {pressure=0.7})
-- his system's leader line: amber, dashed, from the annotation box down to his terminal's screen
local AMBT = pile{{"Mars orange",1.5},{"cadmium yellow",1.2},{"chrome yellow",0.5}}
local d = brush{kind="round", width=1.4, point=0.6}
local p, q = {556, 92}, {492, 196}
local L = math.sqrt((q[1]-p[1])^2 + (q[2]-p[2])^2)
local s = 0
while s < L do
  local s2 = math.min(L, s + 6)
  d:load(AMBT, 0.9)
  d:stroke({{lerp(p[1],q[1],s/L), lerp(p[2],q[2],s/L)}, {lerp(p[1],q[1],s2/L), lerp(p[2],q[2],s2/L)}}, {pressure={0.5,0.5}, ramps={0.01,0.01}, shake=0})
  s = s2 + 4
end
local n = brush{kind="round", width=3.2, point=0.1}
n:load(AMBT, 0.9); n:touch(492, 196, {pressure=0.6})

--@ chunk 54
local HOT = pile{{"zinc white",4},{"lead white",1},{"lemon chrome",0.1}}
local CY = pile{{"zinc white",2},{"cerulean blue",1.3}}
local b = brush{kind="round", width=4, point=0.8}
local pts = {}
for i = 0, 12 do local y = lerp(298, 362, i/12); pts[#pts+1] = {sx(y) - 4, y} end
b:load(CY, 1); b:stroke(pts, {pressure={0.45, 0.45}, swell={0.3, 0.9, 1.3, 0.9, 0.3}, ramps={0.3, 0.3}})
local c = brush{kind="round", width=2.4, point=0.9}
c:load(HOT, 1); c:stroke(pts, {pressure={0.5, 0.5}, swell={0.2, 0.8, 1.2, 0.8, 0.2}, ramps={0.35, 0.35}})
-- ruled rays of her light laid across his metal, fading
local r = brush{kind="round", width=1.2, point=0.6}
for _, y in ipairs({316, 323, 330, 337, 344}) do
  local len = (y == 330) and 46 or rand(18, 34)
  r:load(HOT, 0.8)
  r:stroke({{sx(y) - 4, y}, {sx(y) - 4 - len, y}}, {pressure={0.55, 0.15}, ramps={0.02, 0.6}, shake=0})
end
local t = brush{kind="round", width=7, point=0.2}
t:load(HOT, 1); t:touch(sx(330) - 4, 330, {pressure=0.75})

--@ chunk 55
print(wait(24*60))
local VC = pile{{"cerulean blue",2},{"cobalt blue",0.6},{"zinc white",0.4}}
local HOT = pile{{"zinc white",4},{"lead white",1},{"lemon chrome",0.1}}
local b = brush{kind="round", width=3.4, point=0.8}
local pts = {}
for i = 0, 12 do local y = lerp(300, 360, i/12); pts[#pts+1] = {sx(y) - 3, y} end
b:load(VC, 1); b:stroke(pts, {pressure={0.55, 0.55}, swell={0.3, 0.9, 1.3, 0.9, 0.3}, ramps={0.25, 0.25}})
-- a small branching spark on his side of the contact
local r = brush{kind="round", width=1.8, point=1}
local function bolt(x, y, ang, len, depth)
  local pts = {{x, y}}
  local cx, cy = x, y
  for k = 1, 4 do
    local a = ang + randn(0, 0.45)
    cx, cy = cx + math.cos(a)*len/4, cy + math.sin(a)*len/4
    pts[#pts+1] = {cx, cy}
  end
  r:load(VC, 0.9); r:stroke(pts, {pressure={0.55, 0.05}, ramps={0.05, 0.6}})
  r:load(HOT, 0.8); r:stroke(pts, {pressure={0.3, 0.02}, ramps={0.05, 0.7}})
  if depth > 0 then bolt(pts[3][1], pts[3][2], ang + randn(0, 0.8), len*0.55, depth - 1) end
end
local x0 = sx(330) - 3
bolt(x0, 330, math.pi + 0.5, 34, 1)
bolt(x0, 330, math.pi - 0.6, 30, 1)
bolt(x0, 330, math.pi + 0.05, 22, 0)
local t = brush{kind="round", width=6, point=0.2}
t:load(HOT, 1); t:touch(x0, 330, {pressure=0.75})

--@ chunk 56
print(wait(2*24*60))
-- articulate the wrist: a dark gap and a lit cuff ring where the gauntlet meets the vambrace
local A, B = {30, 680}, {345, 400}
local DK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local LIP = pile{{"lead white",1.5},{"yellow ochre",0.5},{"raw sienna",0.2},{"bone black",0.1}}
local gap, ring = {}, {}
for k = 0, 10 do
  local s = lerp(0.98, -0.98, k/10)
  gap[#gap+1] = axpt(A, B, 63, 63, 0.985, s)
  ring[#ring+1] = axpt(A, B, 64, 64, 0.965, s)
end
local f = brush{kind="filbert", width=5}
f:load(DK, 0.9); f:stroke(gap, {pressure={0.7, 0.6}, ramps={0.05, 0.1}})
local l = brush{kind="round", width=2.4, point=0.6}
l:load(LIP, 0.8); l:stroke(ring, {pressure={0.55, 0.1}, ramps={0.05, 0.6}})

--@ chunk 57
local TG2 = pile{{"bone black",1.2},{"ultramarine ash",1},{"raw sienna",0.3},{"lead white",0.3}}
local m = rect(426, 276, 10, 20) - FING[1] - FING[2]
work(m, {hand="detail", pile=TG2, coverage=4, fill=true, angle=math.pi/2, tool={kind="round", width=1.6}})
