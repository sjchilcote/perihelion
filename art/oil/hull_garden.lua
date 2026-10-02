-- easel session "hull_garden": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.5, linen={18,16}, seed=5151, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"bone brown",2},{"burnt sienna",1},{"lead white",1.5},{"ultramarine blue",0.6}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
VP = {500, 300}
-- the far end of the vault: an arch of glass full of corona glow
FAR = ellipse(500, 300, 70, 80) * above(function(x) return 340 end) + rect(430,300,140,40)
-- floor plane below the wall foot lines; walls; roof
FLOOR = poly({{430,340},{570,340},{1000,560},{1000,667},{0,667},{0,560}})
LWALL = poly({{0,0},{430,230},{430,340},{0,560}})
RWALL = poly({{1000,0},{570,230},{570,340},{1000,560}})
ROOF = poly({{0,0},{1000,0},{570,230},{430,230}})
local R0 = pile{{"ultramarine blue",1},{"bone black",1},{"bone brown",0.6}}
local R1 = pile{{"ultramarine ash",1},{"bone brown",0.8},{"bone black",0.4},{"lead white",0.3}}
local Wl = pile{{"bone brown",1.5},{"ultramarine ash",1},{"bone black",0.4}}
local Fm = pile{{"bone brown",1.4},{"burnt sienna",0.6},{"ultramarine ash",0.8},{"lead white",0.3}}
local glowR = ellipse(500, 120, 330, 160):roughen(20,100,2) * ROOF
work(ROOF - glowR - FAR, {hand="broad", pile=R0, coverage=3, fill=true, angle=0, clip=ROOF})
work(glowR - FAR, {hand="body", pile=R1, coverage=3, fill=true, angle=0, tool="filbert 12", clip=ROOF})
work((LWALL + RWALL) - FAR, {hand="broad", pile=Wl, coverage=3, fill=true, angle=math.pi/2, clip=LWALL + RWALL})
work(FLOOR - FAR, {hand="broad", pile=Fm, coverage=3, fill=true, angle=0, clip=FLOOR})
local F1 = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.2}}
work(FAR, {hand="body", pile=F1, coverage=3.5, fill=true, tool="filbert 6", angle=math.pi/2, clip=FAR})
blend((glowR:grow(30) - glowR:shrink(30)) * ROOF, {angle=0, tool={kind="badger", width=24}, pressure={0.35,0.55}})

--@ chunk 3
-- ribs of the vault: arches receding to the far end
RIBS = {}
local m = nil
for i=0,9 do
  local z = 1 + i*0.75
  local s = 1/z
  local w, base, top = 70 + 520*s, 340 + 280*s, 222 - 300*s
  local pts = {}
  for k=0,40 do local a = math.pi + math.pi*k/40
    local x = 500 + w*math.cos(a)
    local y = base + (base-top)*math.sin(a)*(1 - 0.12*math.cos(a)^2)
    pts[#pts+1] = {x, y}
  end
  RIBS[#RIBS+1] = {pts=pts, s=s}
  local r = ribbon(pts, 4 + 22*s)
  m = m and (m + r) or r
end
RIBM = m - FAR
local K = pile{{"bone black",1.2},{"burnt sienna",0.8},{"bone brown",1}}
work(RIBM, {hand="body", pile=K, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=RIBM})

--@ chunk 4
print(wait(2*24*60))
FLOOR = poly({{430,340},{570,340},{1177,667},{-177,667}})
VAULT = everywhere() - FLOOR - FAR
local G0 = pile{{"ultramarine blue",1},{"bone black",1.1},{"bone brown",0.6}}
local G1 = pile{{"ultramarine ash",1},{"bone brown",0.8},{"bone black",0.5},{"cobalt violet",0.2}}
local G2 = pile{{"ultramarine ash",1},{"lead white",0.5},{"bone brown",0.5},{"yellow ochre",0.15}}
local mid = ellipse(500, 160, 420, 230):roughen(20,100,3) * VAULT
local hi = ellipse(500, 220, 200, 120):roughen(14,80,4) * VAULT
work(VAULT - mid, {hand="broad", pile=G0, coverage=3.5, fill=true, angle=0, clip=VAULT})
work(mid - hi, {hand="body", pile=G1, coverage=3.5, fill=true, tool="filbert 12", angle=0, clip=VAULT})
work(hi, {hand="body", pile=G2, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=VAULT})
blend((mid:grow(30) - mid:shrink(30)) * VAULT, {angle=0, tool={kind="badger", width=24}, pressure={0.4,0.6}})
blend((hi:grow(24) - hi:shrink(24)) * VAULT, {angle=0, tool={kind="badger", width=20}, pressure={0.4,0.6}})
local Fm = pile{{"bone brown",1.4},{"burnt sienna",0.5},{"ultramarine ash",0.8},{"bone black",0.3}}
local Fn = pile{{"bone brown",1.2},{"ultramarine ash",1},{"lead white",0.3},{"yellow ochre",0.2}}
work(FLOOR * below(function(x) return 470 end), {hand="broad", pile=Fm, coverage=3.5, fill=true, angle=0, clip=FLOOR})
work(FLOOR * above(function(x) return 470 end), {hand="body", pile=Fn, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=FLOOR})

--@ chunk 5
print(wait(2*24*60))
local K = pile{{"bone black",1.2},{"burnt sienna",0.8},{"bone brown",1}}
-- longitudinal glazing bars running to the far end
local bars = nil
for _,a in ipairs({-0.95,-0.7,-0.45,-0.22,0,0.22,0.45,0.7,0.95}) do
  local pts = {}
  for i=0,9 do
    local z = 1 + i*0.75; local s = 1/z
    local w, base, top = 70 + 520*s, 340 + 280*s, 222 - 300*s
    local ang = math.pi*(1.5 + a*0.5)
    pts[#pts+1] = {500 + w*math.cos(ang), base + (base-top)*math.sin(ang)*(1 - 0.12*math.cos(ang)^2)}
  end
  local r = ribbon(pts, {7,5,4,3,2.5,2,2,1.5,1.5,1.5})
  bars = bars and (bars + r) or r
end
local m = nil
for _,R in ipairs(RIBS) do local r = ribbon(R.pts, 4 + 22*R.s); m = m and (m + r) or r end
RIBM = (m + bars) - FAR - FLOOR
work(RIBM, {hand="body", pile=K, coverage=4, fill=true, tool="filbert 5", angle=0, clip=RIBM})
-- the floor: middle tone across the seam, a pale path down the middle, bronze channels either side
local Fmid = pile{{"bone brown",1.3},{"ultramarine ash",0.9},{"burnt sienna",0.3},{"lead white",0.15}}
local seam = FLOOR * rect(0,440,1000,70):roughen(10,60,5)
work(seam, {hand="body", pile=Fmid, coverage=3, fill=true, tool="filbert 10", angle=0, clip=FLOOR})
PATH = poly({{486,340},{514,340},{640,667},{360,667}})
CHL = poly({{478,340},{484,340},{344,667},{318,667}})
CHR = poly({{516,340},{522,340},{682,667},{656,667}})
work(PATH, {hand="body", pile=pile{{"lead white",1},{"yellow ochre",0.4},{"bone brown",0.8},{"ultramarine ash",0.4}}, coverage=3.5, fill=true, tool="filbert 8", angle=math.pi/2, clip=PATH})
work(CHL + CHR, {hand="body", pile=pile{{"burnt sienna",1},{"bone brown",1},{"bone black",0.5}}, coverage=4, fill=true, tool="filbert 4", angle=math.pi/2, clip=CHL + CHR})

--@ chunk 6
print(wait(2*24*60))
-- the beds either side: a graded mid-dark ground, lighter far, darker near
BEDS = FLOOR - PATH - CHL - CHR
local B1 = pile{{"bone brown",1.3},{"ultramarine ash",0.9},{"lead white",0.25},{"burnt sienna",0.3}}
local B2 = pile{{"bone brown",1.5},{"ultramarine ash",0.7},{"burnt sienna",0.4},{"bone black",0.25}}
local B3 = pile{{"bone brown",1.5},{"bone black",0.6},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
work(BEDS * above(function(x) return 420 end), {hand="body", pile=B1, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=BEDS})
work(BEDS * below(function(x) return 420 end) * above(function(x) return 540 end), {hand="body", pile=B2, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=BEDS})
work(BEDS * below(function(x) return 540 end), {hand="broad", pile=B3, coverage=3.5, fill=true, angle=0, clip=BEDS})
for _,y in ipairs({420, 540}) do blend(BEDS * rect(0,y-22,1000,44), {angle=0, tool={kind="badger", width=20}, pressure={0.35,0.55}}) end
-- path: graded too, paler toward the far light
local P1 = pile{{"lead white",1},{"yellow ochre",0.35},{"bone brown",0.6},{"ultramarine ash",0.4}}
local P2 = pile{{"bone brown",1},{"ultramarine ash",0.6},{"lead white",0.5},{"yellow ochre",0.2}}
work(PATH * below(function(x) return 520 end), {hand="body", pile=P2, coverage=3.5, fill=true, tool="filbert 8", angle=math.pi/2, clip=PATH})
work(PATH * above(function(x) return 520 end), {hand="body", pile=P1, coverage=3.5, fill=true, tool="filbert 6", angle=math.pi/2, clip=PATH})
blend(PATH * rect(0,495,1000,50), {angle=math.pi/2, tool={kind="badger", width=16}, pressure={0.35,0.55}})

--@ chunk 7
print(wait(2*24*60))
BONEM = pile{{"lead white",1.5},{"ultramarine ash",0.5},{"yellow ochre",0.3},{"bone brown",0.3}}
BONEL = pile{{"lead white",3},{"yellow ochre",0.5},{"raw sienna",0.15}}
BONED = pile{{"ultramarine ash",1},{"bone brown",0.8},{"lead white",0.4}}
GA = math.pi*(3-math.sqrt(5))
function gpos(z, X) return 500 + X/z, 340 + 327/z end
function shade_form(M, cx, sideRight)
  -- lit side toward the vault's middle
  local half = sideRight and rect(cx, 0, 1000, 667) or rect(0, 0, cx, 667)
  local sh = sideRight and rect(0, 0, cx, 667) or rect(cx, 0, 1000, 667)
  work(M, {hand="detail", pile=BONEM, coverage=3.5, fill=true, clip=M})
  work(M * sh, {hand="detail", pile=BONED, coverage=2, clip=M})
  work(M * half, {hand="detail", pile=BONEL, coverage=2.2, clip=M})
end
function tree(z, X, H, seed)
  local x, y = gpos(z, X); local s = 1/z
  local h = H*s
  local trunk = {{x, y}, {x + 6*s, y - h*0.4}, {x - 4*s, y - h*0.75}, {x, y - h}}
  local M = ribbon(trunk, {22*s, 16*s, 12*s, 8*s}) + ellipse(x, y, 20*s, 6*s)
  for k=1,9 do
    local t = 0.35 + 0.6*k/9
    local by = y - h*t
    local a = k*GA + seed
    local dir = math.cos(a)
    local L = (130 - 70*t)*s
    local pts = {}
    for j=0,6 do local u = j/6
      local cur = a + u*2.2
      pts[#pts+1] = {x + dir*L*u + math.cos(cur)*L*0.25*u*u, by - L*0.5*u + math.sin(cur)*L*0.25*u*u}
    end
    M = M + ribbon(pts, {7*s, 5*s, 4*s, 3*s, 2.5*s, 2*s, 1.5*s})
  end
  shade_form(M, x, X < 0)
  return M
end
function disc(z, X, H, R)
  local x, y = gpos(z, X); local s = 1/z
  local top = y - H*s
  local M = ribbon({{x, y}, {x + 4*s, y - H*s*0.5}, {x, top}}, {9*s, 7*s, 6*s}) + ellipse(x, top, R*s, R*s*0.92)
  shade_form(M, x, X < 0)
  -- the seed-head: golden-angle florets
  local r = brush{kind="round", width=math.max(2, 5*s), point=0}
  local n = math.floor(60 + 140*s)
  for i=1,n do
    local rr = R*s*0.88*math.sqrt(i/n); local a = i*GA
    r:reload(BONED, 0.5); r:touch(x + rr*math.cos(a), top + rr*0.92*math.sin(a), {pressure=0.5})
  end
  return M
end
function fan(z, X, H)
  local x, y = gpos(z, X); local s = 1/z
  local M = ellipse(x, y, 12*s, 5*s)
  for k=0,12 do
    local a = -math.pi*(0.12 + 0.76*k/12)
    local L = H*s*(0.8 + 0.2*math.sin(k*1.7))
    M = M + ribbon({{x, y}, {x + math.cos(a)*L*0.5, y + math.sin(a)*L*0.5}, {x + math.cos(a)*L, y + math.sin(a)*L}}, {5*s, 3.5*s, 2*s})
  end
  shade_form(M, x, X < 0)
  return M
end
function shell(z, X, R)
  local x, y = gpos(z, X); local s = 1/z
  local pts, ws = {}, {}
  for i=0,40 do local t = i/40; local a = t*4*math.pi; local rr = R*s*math.exp(-1.5*(1-t))*t
    pts[#pts+1] = {x + rr*math.cos(a), y - R*s*0.6 + rr*0.8*math.sin(a)}; ws[#ws+1] = 1 + 18*s*t*t end
  local M = ribbon(pts, ws) + ellipse(x + 4*s, y - R*s*0.55, R*s*0.75, R*s*0.6)
  shade_form(M, x, X < 0)
  local r = brush{kind="round", width=math.max(2,4*s), point=0.6}
  r:reload(BONED, 0.6); r:stroke(pts, {pressure={r:pressure_for(0.6), r:pressure_for(2*s+0.6)}})
  return M
end
FORMS = nil
local function add(m) FORMS = FORMS and (FORMS + m) or m end
-- farthest first
add(tree(7, -260, 260, 1.0)); add(tree(7, 260, 240, 2.0))
add(disc(6, -400, 160, 50)); add(fan(6, 420, 140))
add(tree(5, 330, 300, 3.0)); add(shell(5, -230, 70))
add(disc(4.2, 440, 200, 60)); add(tree(4, -380, 320, 4.0))

--@ chunk 8
local function add(m) FORMS = FORMS + m end
add(fan(3.4, -300, 260)); add(shell(3.4, 260, 110))
add(tree(3, 420, 620, 5.0)); add(disc(3, -470, 380, 90))
add(disc(2.6, 250, 300, 80)); add(tree(2.5, -330, 700, 6.0))
add(fan(2.2, 520, 340)); add(shell(2.1, -230, 150))
add(tree(1.9, 560, 760, 7.0)); add(disc(1.8, -560, 420, 120))
add(fan(1.45, -330, 300)); add(disc(1.4, 300, 320, 100))

--@ chunk 9
print(wait(2*24*60))
TREES = {{7,-260,260,1.0},{7,260,240,2.0},{5,330,300,3.0},{4,-380,320,4.0},{3,420,620,5.0},{2.5,-330,700,6.0},{1.9,560,760,7.0}}
DISCS = {{6,-400,160,50},{4.2,440,200,60},{3,-470,380,90},{2.6,250,300,80},{1.8,-560,420,120},{1.4,300,320,100}}
-- spiral crowns on the trees: long branches that curl into golden spirals at their tips
for _,T in ipairs(TREES) do
  local z, X, H, seed = T[1], T[2], T[3], T[4]
  local x, y = gpos(z, X); local s = 1/z; local h = H*s
  local M = nil
  for k=1,7 do
    local t = 0.45 + 0.55*k/7
    local bx, by = x, y - h*t
    local side = (k % 2 == 0) and 1 or -1
    local L = (260 - 120*t)*s
    local pts, ws = {}, {}
    for j=0,14 do local u = j/14
      local ang = -math.pi/2 + side*(0.9 - 0.5*u) + side*u*u*3.2
      local rr = L*u
      pts[#pts+1] = {bx + side*rr*0.9 + math.cos(ang)*rr*0.25, by - rr*0.45 + math.sin(ang)*rr*0.25}
      ws[#ws+1] = math.max(1, (9 - 7.5*u)*s*1.6)
    end
    local r = ribbon(pts, ws); M = M and (M + r) or r
  end
  shade_form(M, x, X < 0)
  FORMS = FORMS + M
end

--@ chunk 10
print(wait(2*24*60))
-- disc heads: a shadow crescent on the side away from the light, and visible florets
local FL = pile{{"bone brown",1.2},{"burnt sienna",0.4},{"ultramarine ash",0.6}}
for _,D in ipairs(DISCS) do
  local z, X, Hh, R = D[1], D[2], D[3], D[4]
  local x, y = gpos(z, X); local s = 1/z; local top = y - Hh*s
  local rr = R*s
  local away = (X < 0) and -1 or 1
  local cres = ellipse(x, top, rr, rr*0.92) - ellipse(x - away*rr*0.35, top - rr*0.1, rr*0.95, rr*0.9)
  work(cres, {hand="detail", pile=BONED, coverage=3, fill=true, clip=cres})
  local b = brush{kind="round", width=math.max(2.5, 7*s), point=0}
  local n = math.floor(40 + 160*s)
  for i=1,n do
    local q = rr*0.85*math.sqrt(i/n); local a = i*GA
    b:reload(FL, 0.7); b:touch(x + q*math.cos(a), top + q*0.92*math.sin(a), {pressure=0.75})
  end
end
-- contact shadows at every foot
local CS = pile{{"bone black",1},{"bone brown",1},{"ultramarine blue",0.3}}
local all = {}
for _,T in ipairs(TREES) do all[#all+1] = {T[1],T[2],26} end
for _,D in ipairs(DISCS) do all[#all+1] = {D[1],D[2],14} end
for _,F in ipairs({{6,420},{3.4,-300},{2.2,520},{1.45,-330}}) do all[#all+1] = {F[1],F[2],30} end
for _,S in ipairs({{5,-230,70},{3.4,260,110},{2.1,-230,150}}) do all[#all+1] = {S[1],S[2],S[3]*0.9} end
for _,a in ipairs(all) do
  local x, y = gpos(a[1], a[2]); local s = 1/a[1]
  local e = ellipse(x + 6*s, y + 3*s, a[3]*s*1.4 + 4, a[3]*s*0.35 + 2) - FORMS
  work(e, {hand="detail", pile=CS, coverage=3, fill=true, clip=e})
end

--@ chunk 11
print(wait(2*24*60))
-- the Commando walking away down the path, small
CX, CY = 488, 486
local h = 78
local K = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.5}}
FIG = ellipse(CX, CY - h*0.9, 6.5, 7.5)
  + poly({{CX-13,CY-h*0.8},{CX+13,CY-h*0.8},{CX+11,CY-h*0.45},{CX-11,CY-h*0.45}}, true)
  + ribbon({{CX-6,CY-h*0.46},{CX-8,CY-h*0.22},{CX-9,CY}}, {8,7,6})
  + ribbon({{CX+6,CY-h*0.46},{CX+7,CY-h*0.24},{CX+5,CY-h*0.06}}, {8,7,6})
  + ribbon({{CX-14,CY-h*0.78},{CX-17,CY-h*0.6},{CX-17,CY-h*0.44}}, {6,5,5})
  + ribbon({{CX+14,CY-h*0.78},{CX+17,CY-h*0.6},{CX+18,CY-h*0.44}}, {6,5,5})
  + ribbon({{CX+20,CY-h*1.05},{CX+18,CY-h*0.5}}, 4)
work(FIG, {hand="detail", pile=K, coverage=5, fill=true, clip=FIG})
RAG = poly({{CX-13,CY-h*0.8},{CX+13,CY-h*0.8},{CX+12,CY-h*0.6},{CX+8,CY-h*0.52},{CX+3,CY-h*0.58},{CX-2,CY-h*0.5},{CX-7,CY-h*0.57},{CX-12,CY-h*0.53}})
work(RAG, {hand="detail", pile=pile{{"Mars red",1.5},{"rose madder",1},{"vermilion",0.5}}, coverage=5, fill=true, clip=RAG})
local sh = ellipse(CX + 4, CY + 2, 18, 3.5)
work(sh - FIG, {hand="detail", pile=pile{{"bone black",1},{"bone brown",1}}, coverage=3, fill=true, clip=sh - FIG})
-- a small bronze bench on the right bed, by the path
local bx, by = gpos(2.0, 230)
BENCH = poly({{bx-40,by-24},{bx+40,by-26},{bx+44,by-18},{bx-38,by-16}}) + rect(bx-34,by-18,5,20) + rect(bx+32,by-20,5,22) + poly({{bx-40,by-40},{bx+40,by-42},{bx+40,by-36},{bx-40,by-34}})
work(BENCH, {hand="detail", pile=pile{{"burnt sienna",1},{"bone brown",1},{"bone black",0.4}}, coverage=5, fill=true, clip=BENCH})
local bsh = ellipse(bx + 8, by + 3, 46, 5) - BENCH
work(bsh, {hand="detail", pile=pile{{"bone black",1},{"bone brown",1}}, coverage=3, fill=true, clip=bsh})
BX, BY = bx, by

--@ chunk 12
print(wait(2*24*60))
local r = brush{kind="round", width=4, point=0.8}
local HOT = pile{{"lead white",2.5},{"yellow ochre",0.3},{"lemon chrome",0.1}}
local PALE = pile{{"lead white",2},{"yellow ochre",0.4},{"ultramarine ash",0.2}}
-- florets: pale touches between the dark ones, so the heads read as spirals not spots
for _,D in ipairs(DISCS) do
  local z, X, Hh, R = D[1], D[2], D[3], D[4]
  local x, y = gpos(z, X); local s = 1/z; local top = y - Hh*s; local rr = R*s
  local b = brush{kind="round", width=math.max(2.5, 6*s), point=0}
  local n = math.floor(40 + 160*s)
  for i=1,n do
    local q = rr*0.85*math.sqrt((i+0.5)/n); local a = (i+0.5)*GA
    b:reload(PALE, 0.6); b:touch(x + q*math.cos(a), top + q*0.92*math.sin(a), {pressure=0.6})
  end
  local away = (X < 0) and -1 or 1
  local arc = {} for k=0,10 do local a = math.pi*1.5 - away*(0.2 + 1.1*k/10); arc[#arc+1] = {x + rr*0.97*math.cos(a), top + rr*0.9*math.sin(a)} end
  r:reload(HOT, 0.6); r:stroke(arc, {pressure={r:pressure_for(1), r:pressure_for(2.5*s+1)}, swell={0.3,1,1,0.4}})
end
-- light down the lit side of every trunk
for _,T in ipairs(TREES) do
  local z, X, H = T[1], T[2], T[3]
  local x, y = gpos(z, X); local s = 1/z; local h = H*s
  local side = (X < 0) and 1 or -1
  r:reload(HOT, 0.6); r:stroke({{x + side*(7*s), y - h}, {x + side*(10*s), y - h*0.6}, {x + side*(12*s), y - 4}}, {pressure={r:pressure_for(1), r:pressure_for(3*s+0.5)}})
end
-- the far end: corona light through the glass
local GL = pile{{"zinc white",2},{"lemon chrome",0.3},{"cadmium yellow",0.2}}
local core = ellipse(500, 270, 40, 50) * FAR
work(core, {hand="detail", pile=GL, coverage=4, fill=true, clip=FAR})
local halo = (ellipse(500, 270, 140, 140) - FAR) - RIBM
stipple(halo, {pile=pile{{"lead white",2},{"yellow ochre",0.5},{"Mars orange",0.1}}, width=2.4, pressure={0.3,0.6}, coverage=function(x,y) local d=math.sqrt((x-500)^2+(y-270)^2) return 2.2*math.exp(-(d-60)/30) end, feather=0.6})
-- stars in the dark beyond the glass
local st = brush{kind="round", width=2, point=1}
for _,p in ipairs({{40,40},{90,120},{30,200},{150,30},{960,50},{900,140},{970,230},{860,40},{60,300},{940,320},{20,380},{980,390}}) do
  st:reload(pile{{"zinc white",1}}, 0.5); st:touch(p[1], p[2], {pressure=0.3})
end
-- the channels catch a line of light; the Commando's helm and shoulders too
r:reload(pile{{"yellow ochre",1},{"Mars orange",0.5},{"lead white",0.8}}, 0.5); r:stroke({{483,342},{420,500},{346,662}}, {pressure={r:pressure_for(0.5), r:pressure_for(2)}, clip=CHL:grow(1)})
r:reload(pile{{"yellow ochre",1},{"Mars orange",0.5},{"lead white",0.8}}, 0.5); r:stroke({{517,342},{580,500},{656,662}}, {pressure={r:pressure_for(0.5), r:pressure_for(2)}, clip=CHR:grow(1)})
local rim = pile{{"lead white",2},{"yellow ochre",0.5}}
local h = 78
local hp = {} for i=0,8 do local a = math.pi*(1.15 + 0.7*i/8); hp[#hp+1] = {CX + 6.5*math.cos(a), CY - h*0.9 + 7.5*math.sin(a)} end
r:reload(rim, 0.6); r:stroke(hp, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})
r:reload(rim, 0.5); r:stroke({{CX-13,CY-h*0.8},{CX,CY-h*0.81},{CX+13,CY-h*0.8}}, {pressure={r:pressure_for(1), r:pressure_for(1)}})
r:reload(pile{{"vermilion",1},{"lead white",0.3}}, 0.5); r:stroke({{CX-11,CY-h*0.77},{CX+11,CY-h*0.77}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})
r:reload(rim, 0.5); r:stroke({{BX-40,BY-41},{BX+40,BY-43}}, {pressure={r:pressure_for(1), r:pressure_for(1)}})
r:reload(rim, 0.5); r:stroke({{BX-40,BY-25},{BX+40,BY-27}}, {pressure={r:pressure_for(1), r:pressure_for(1)}})

--@ chunk 13
local halo = (ellipse(500, 270, 150, 150) - FAR) - RIBM - FORMS:grow(2) - FIG:grow(2)
blend(halo, {angle=function(x,y) return math.atan(y-270,x-500)+math.pi/2 end, tool={kind="badger", width=16}, pressure={0.35,0.55}})
-- foreground framing: a great sunflower-disc cut by the left edge, a big shell at lower right
FORMS = FORMS + disc(1.05, -620, 300, 170)
FORMS = FORMS + shell(1.1, 520, 230)

--@ chunk 14
print(wait(3*24*60))
local FL = pile{{"bone brown",1.2},{"burnt sienna",0.4},{"ultramarine ash",0.6}}
local PALE = pile{{"lead white",2},{"yellow ochre",0.4},{"ultramarine ash",0.2}}
local HOT = pile{{"lead white",2.5},{"yellow ochre",0.3},{"lemon chrome",0.1}}
-- the great disc at the left edge
local x, y = gpos(1.05, -620); local s = 1/1.05; local top = y - 300*s; local rr = 170*s
local cres = ellipse(x, top, rr, rr*0.92) - ellipse(x + rr*0.3, top - rr*0.08, rr*0.95, rr*0.9)
work(cres, {hand="body", pile=BONED, coverage=3, fill=true, tool="filbert 6", clip=cres})
local b = brush{kind="round", width=9, point=0}
for i=1,520 do local q = rr*0.9*math.sqrt(i/520); local a = i*GA
  local px, py = x + q*math.cos(a), top + q*0.92*math.sin(a)
  if px > -5 then b:reload(FL, 0.7); b:touch(px, py, {pressure=0.7}) end end
local r = brush{kind="round", width=6, point=0.8}
local arc = {} for k=0,10 do local a = -math.pi*0.5 + 0.9*k/10; arc[#arc+1] = {x + rr*0.97*math.cos(a), top + rr*0.9*math.sin(a)} end
r:reload(HOT, 0.6); r:stroke(arc, {pressure={r:pressure_for(2), r:pressure_for(5)}, swell={0.3,1,1,0.4}})
-- the great shell at lower right: shadow on its outer side, the spiral groove, growth lines
local sx, sy = gpos(1.1, 520); local ss = 1/1.1; local R = 230*ss
local cx, cy = sx + 4*ss, sy - R*0.55
local shd = ellipse(cx, cy, R*0.75, R*0.6) * rect(cx + R*0.15, 0, 1000, 700)
work(shd, {hand="body", pile=BONED, coverage=3, fill=true, tool="filbert 8", clip=ellipse(cx, cy, R*0.75, R*0.6)})
local pts = {} for i=0,60 do local t = i/60; local a = t*4*math.pi; local q = R*0.7*math.exp(-1.5*(1-t))*t
  pts[#pts+1] = {cx + q*math.cos(a), cy + q*0.8*math.sin(a)} end
local g = brush{kind="round", width=10, point=0.6}
g:reload(pile{{"bone brown",1.2},{"ultramarine ash",0.8},{"bone black",0.3}}, 0.8)
g:stroke(pts, {pressure={g:pressure_for(1), g:pressure_for(8)}})
for k=0,10 do local a = math.pi*(0.6 + 0.9*k/10)
  r:reload(BONED, 0.5); r:stroke({{cx + R*0.3*math.cos(a), cy + R*0.25*math.sin(a)}, {cx + R*0.72*math.cos(a), cy + R*0.58*math.sin(a)}}, {pressure={r:pressure_for(1), r:pressure_for(2)}}) end
local ha = {} for k=0,10 do local a = math.pi*(1.0 + 0.55*k/10); ha[#ha+1] = {cx + R*0.73*math.cos(a), cy + R*0.58*math.sin(a)} end
r:reload(HOT, 0.6); r:stroke(ha, {pressure={r:pressure_for(5), r:pressure_for(2)}, swell={0.4,1,1,0.4}})
-- spiral grooves on the mid-ground shells
for _,S in ipairs({{5,-230,70},{3.4,260,110},{2.1,-230,150}}) do
  local qx, qy = gpos(S[1], S[2]); local q = 1/S[1]
  local p = {} for i=0,40 do local t=i/40; local a=t*4*math.pi; local rr2 = S[3]*q*math.exp(-1.5*(1-t))*t
    p[#p+1] = {qx + 4*q + rr2*0.7*math.cos(a), qy - S[3]*q*0.55 + rr2*0.56*math.sin(a)} end
  g:reload(pile{{"bone brown",1.2},{"ultramarine ash",0.8}}, 0.7); g:stroke(p, {pressure={g:pressure_for(0.8), g:pressure_for(5*q+1)}})
end
