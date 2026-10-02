-- easel session "ratio_stack": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen=18, seed=77,
  ground={{pile={{"ultramarine blue",2},{"bone black",1.2},{"cobalt violet",0.6},{"zinc white",0.5}}, um=90, apply="knife", texture=0.35}}}
-- the stack geometry, shared by later chunks
LY = {}
for i=1,10 do
  local y = 105 + (i-1)*104
  local w = 390 - (i-1)*25
  local d = 62 - (i-1)*2.5
  local s = 70 - (i-1)*3
  local cx = 500 + ((i%3)-1)*14     -- a little clumsy: not quite aligned
  LY[i] = {cx=cx, y=y, w=w, d=d, s=s}
end
SHX = 540
function slab(i)
  local L = LY[i]
  return poly({{L.cx-L.w+L.s, L.y-L.d}, {L.cx+L.w+L.s, L.y-L.d}, {L.cx+L.w-L.s, L.y+L.d}, {L.cx-L.w-L.s, L.y+L.d}})
end
function hole(i)
  local L = LY[i]
  local r = 34 + i*1.5
  return ellipse(SHX + (L.y-LY[10].y)*0.0, L.y, r, r*L.d/90):roughen(5, 18, i)
end
-- warm light rising from the bottom of the stack, and the shaft where the layers gave way
local glow = pile{{"zinc white",3},{"Indian yellow",0.6},{"Mars orange",0.3}}
local glow2 = pile{{"zinc white",2},{"rose madder",0.3},{"cobalt violet",0.3},{"ultramarine blue",0.3}}
work(ellipse(SHX,1120,200,90):soften(30), {hand="body", tool="filbert 8", pile=glow2, coverage=2, fill=true, angle=0, length={20,60}, edge="soft"})
work(ellipse(SHX,1125,110,55):soften(15), {hand="body", tool="filbert 6", pile=glow, coverage=2.5, fill=true, angle=0, length={14,40}, edge="soft"})
work(rect(SHX-28,40,56,1080):roughen(4,30,2), {hand="body", tool="filbert 5", pile=glow, coverage=2.2, fill=true, angle=1.57, length={30,90}, edge="soft"})

--@ chunk 2
LC = {
 {{"zinc white",3},{"cerulean blue",0.6}},
 {{"zinc white",3},{"ultramarine ash",0.6}},
 {{"zinc white",3},{"cerulean blue",0.4},{"viridian",0.15}},
 {{"zinc white",3},{"emerald green",0.35}},
 {{"zinc white",3},{"cobalt violet",0.7}},
 {{"zinc white",3},{"cerulean blue",0.8},{"emerald green",0.2}},
 {{"zinc white",3},{"lemon chrome",0.6}},
 {{"zinc white",3},{"rose madder",0.4},{"magenta",0.15}},
 {{"zinc white",3},{"Mars orange",0.4},{"cadmium yellow",0.3}},
 {{"zinc white",3},{"Indian yellow",0.4},{"vermilion",0.15}},
}
LP = {}
for i=10,1,-1 do
  local t = {}; for _,c in ipairs(LC[i]) do t[#t+1] = c end; t.medium = 0.55
  LP[i] = pile(t)
  local m = slab(i) - hole(i)
  work(m, {hand="body", tool="filbert 6", pile=LP[i], coverage=1.7, fill=true, clip=true, angle=0.0, length={20,60}})
end

--@ chunk 3
print(wait(2*24*60))
function PT(i,u,v) local L = LY[i]; return {L.cx + u*L.w - v*L.s, L.y + v*L.d} end
function mk(i, pts, p, width, pr, load)
  local b = brush{kind="round", width=width or 2, point=0.6}
  b:load(p, load or 0.8)
  local q = {}; for _,t in ipairs(pts) do q[#q+1] = PT(i,t[1],t[2]) end
  b:stroke(q, {pressure=pr or {0.6,0.6}, ramps={0.05,0.1}, clip=slab(i) - hole(i)})
end
navy = pile{{"ultramarine blue",2},{"bone black",0.6},{"zinc white",0.3}}
orng = pile{{"Mars orange",1},{"cadmium yellow",1},{"zinc white",0.5}}
cyan = pile{{"cerulean blue",1},{"zinc white",1},{"emerald green",0.2}}
pink = pile{{"magenta",1},{"zinc white",1}}
redp = pile{{"vermilion",1},{"cadmium red",0.5}}
blue = pile{{"cobalt blue",1},{"zinc white",0.4}}
-- 1 status summary bar: segments and three chips
for k=0,5 do local u0 = -0.85 + k*0.22; mk(1, {{u0,-0.1},{u0+0.15,-0.1}}, navy, 6, {0.9,0.9}) end
mk(1, {{0.62,-0.1},{0.66,-0.1}}, orng, 7, {1,1}); mk(1, {{0.72,-0.1},{0.76,-0.1}}, blue, 7, {1,1}); mk(1, {{0.82,-0.1},{0.86,-0.1}}, blue, 7, {1,1})
mk(1, {{-0.9,0.45},{0.9,0.45}}, navy, 1.5, {0.5,0.5})
-- 2 dashboard: dials with needles
for k,u in ipairs({-0.6,-0.1,0.45}) do
  local c = PT(2,u,0)
  local b = brush{kind="round", width=2, point=0.6}; b:load(navy, 0.8)
  local pts = {}; for a=0,32 do local t = a/32*2*math.pi; pts[#pts+1] = {c[1]+math.cos(t)*44, c[2]+math.sin(t)*20} end
  b:stroke(pts, {pressure={0.6,0.6}})
  local nb = brush{kind="round", width=2.5, point=0.8}; nb:load(k==2 and redp or orng, 0.9)
  nb:stroke({c, {c[1]+math.cos(-0.6-k*0.5)*36, c[2]+math.sin(-0.6-k*0.5)*16}}, {pressure={0.9,0.3}})
end
-- 3 ledger: ruled lines, column rules, entries
for k=-3,3 do mk(3, {{-0.9,k*0.25},{0.9,k*0.25}}, blue, 1.2, {0.4,0.4}, 0.6) end
for _,u in ipairs({-0.5,0.35,0.65}) do mk(3, {{u,-0.85},{u,0.85}}, redp, 1.2, {0.4,0.4}, 0.6) end
for k=-3,2 do mk(3, {{-0.45,k*0.25+0.12},{-0.45+rand(0.2,0.6),k*0.25+0.12}}, navy, 1.6, {0.6,0.5}); mk(3, {{0.4,k*0.25+0.12},{0.58,k*0.25+0.12}}, navy, 1.6, {0.6,0.5}) end
-- 4 scanline field
for k=0,22 do local v = -0.92 + k*0.084; mk(4, {{-1,v},{1,v}}, (k%2==0) and cyan or navy, 1.3, {0.35,0.35}, 0.5) end
-- 5 wireframe grid, a low-poly lattice
for k=-4,4 do mk(5, {{k*0.22,-1},{k*0.22,1}}, cyan, 1.5, {0.5,0.5}) end
for k=-3,3 do mk(5, {{-1,k*0.28},{1,k*0.28}}, cyan, 1.5, {0.5,0.5}) end
for k=-3,2 do mk(5, {{k*0.22-0.1,-0.84},{k*0.22+0.34,0.84}}, pink, 1.2, {0.4,0.4}, 0.6) end
-- 6 caveats: footnote marks and small print
for r=-2,2 do
  mk(6, {{-0.8,r*0.32},{-0.78,r*0.32}}, redp, 4, {1,1})
  local u = -0.7
  while u < 0.8 do local l = rand(0.05,0.18); mk(6, {{u,r*0.32},{u+l,r*0.32}}, navy, 1.6, {0.6,0.6}); u = u + l + 0.04 end
end
-- 7 VMU pixels: a little blocky heart among squares
local hb = {{0,0},{1,0},{3,0},{4,0},{-1,1},{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{0,2},{1,2},{2,2},{3,2},{4,2},{1,3},{2,3},{3,3},{2,4}}
for _,p in ipairs(hb) do local u = 0.3 + p[1]*0.06; local v = -0.6 + p[2]*0.28; mk(7, {{u,v},{u+0.03,v}}, pink, 7, {1,1}) end
for k=0,9 do local u = -0.85 + (k%5)*0.12; local v = -0.5 + (k//5)*0.5; mk(7, {{u,v},{u+0.04,v}}, navy, 6, {1,1}) end
-- 8 window chrome: title bar, buttons, scrollbar
mk(8, {{-0.9,-0.75},{0.9,-0.75}}, blue, 8, {1,1})
for k=0,2 do mk(8, {{0.6+k*0.1,-0.75},{0.63+k*0.1,-0.75}}, (k==2) and redp or pink, 5, {1,1}) end
mk(8, {{0.88,-0.5},{0.88,0.8}}, navy, 3, {0.8,0.8}); mk(8, {{0.88,-0.2},{0.88,0.1}}, blue, 4, {1,1})
-- 9 loading: progress bar and the swirl
mk(9, {{-0.8,0.45},{0.6,0.45}}, navy, 6, {1,1}); mk(9, {{-0.8,0.45},{-0.05,0.45}}, orng, 5, {1,1})
local c = PT(9,-0.45,-0.2)
local sw = brush{kind="round", width=4, point=0.8}; sw:load(orng, 1.0)
local pts = {}; for a=0,40 do local t = a/40*2.6*math.pi; local r = 2 + a*0.75; pts[#pts+1] = {c[1]+math.cos(t)*r, c[2]+math.sin(t)*r*0.45} end
sw:stroke(pts, {pressure={0.3,1.0}})
-- 10 warm: soft dotted lines like handwriting
for r=-1,1 do for k=0,10 do local u = -0.8 + k*0.15 + rand(-0.02,0.02); mk(10, {{u,r*0.4},{u+0.06,r*0.4+rand(-0.05,0.05)}}, orng, 2, {0.7,0.3}) end end

--@ chunk 4
print(wait(2*24*60))
function PT(i,u,v) local L = LY[i]; return {L.cx + u*L.w - v*L.s, L.y + v*L.d} end
function mk(i, pts, p, width, pr, load)
  local b = brush{kind="round", width=(width or 2)*2.0, point=0.5}
  b:load(p, 1.0)
  local q = {}; for _,t in ipairs(pts) do q[#q+1] = PT(i,t[1],t[2]) end
  b:stroke(q, {pressure={1.0,1.0}, ramps={0.05,0.1}, clip=slab(i) - hole(i)})
end
navy = pile{{"ultramarine blue",2},{"bone black",0.6},{"zinc white",0.3}}
orng = pile{{"Mars orange",1},{"cadmium yellow",1},{"zinc white",0.5}}
cyan = pile{{"cerulean blue",1},{"zinc white",1},{"emerald green",0.2}}
pink = pile{{"magenta",1},{"zinc white",1}}
redp = pile{{"vermilion",1},{"cadmium red",0.5}}
blue = pile{{"cobalt blue",1},{"zinc white",0.4}}
-- 1 status summary bar: segments and three chips
for k=0,5 do local u0 = -0.85 + k*0.22; mk(1, {{u0,-0.1},{u0+0.15,-0.1}}, navy, 6, {0.9,0.9}) end
mk(1, {{0.62,-0.1},{0.66,-0.1}}, orng, 7, {1,1}); mk(1, {{0.72,-0.1},{0.76,-0.1}}, blue, 7, {1,1}); mk(1, {{0.82,-0.1},{0.86,-0.1}}, blue, 7, {1,1})
mk(1, {{-0.9,0.45},{0.9,0.45}}, navy, 1.5, {0.5,0.5})
-- 2 dashboard: dials with needles
for k,u in ipairs({-0.6,-0.1,0.45}) do
  local c = PT(2,u,0)
  local b = brush{kind="round", width=2, point=0.6}; b:load(navy, 0.8)
  local pts = {}; for a=0,32 do local t = a/32*2*math.pi; pts[#pts+1] = {c[1]+math.cos(t)*44, c[2]+math.sin(t)*20} end
  b:stroke(pts, {pressure={0.6,0.6}})
  local nb = brush{kind="round", width=2.5, point=0.8}; nb:load(k==2 and redp or orng, 0.9)
  nb:stroke({c, {c[1]+math.cos(-0.6-k*0.5)*36, c[2]+math.sin(-0.6-k*0.5)*16}}, {pressure={0.9,0.3}})
end
-- 3 ledger: ruled lines, column rules, entries
for k=-3,3 do mk(3, {{-0.9,k*0.25},{0.9,k*0.25}}, blue, 1.2, {0.4,0.4}, 0.6) end
for _,u in ipairs({-0.5,0.35,0.65}) do mk(3, {{u,-0.85},{u,0.85}}, redp, 1.2, {0.4,0.4}, 0.6) end
for k=-3,2 do mk(3, {{-0.45,k*0.25+0.12},{-0.45+rand(0.2,0.6),k*0.25+0.12}}, navy, 1.6, {0.6,0.5}); mk(3, {{0.4,k*0.25+0.12},{0.58,k*0.25+0.12}}, navy, 1.6, {0.6,0.5}) end
-- 4 scanline field
for k=0,22 do local v = -0.92 + k*0.084; mk(4, {{-1,v},{1,v}}, (k%2==0) and cyan or navy, 1.3, {0.35,0.35}, 0.5) end
-- 5 wireframe grid, a low-poly lattice
for k=-4,4 do mk(5, {{k*0.22,-1},{k*0.22,1}}, cyan, 1.5, {0.5,0.5}) end
for k=-3,3 do mk(5, {{-1,k*0.28},{1,k*0.28}}, cyan, 1.5, {0.5,0.5}) end
for k=-3,2 do mk(5, {{k*0.22-0.1,-0.84},{k*0.22+0.34,0.84}}, pink, 1.2, {0.4,0.4}, 0.6) end
-- 6 caveats: footnote marks and small print
for r=-2,2 do
  mk(6, {{-0.8,r*0.32},{-0.78,r*0.32}}, redp, 4, {1,1})
  local u = -0.7
  while u < 0.8 do local l = rand(0.05,0.18); mk(6, {{u,r*0.32},{u+l,r*0.32}}, navy, 1.6, {0.6,0.6}); u = u + l + 0.04 end
end
-- 7 VMU pixels: a little blocky heart among squares
local hb = {{0,0},{1,0},{3,0},{4,0},{-1,1},{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{0,2},{1,2},{2,2},{3,2},{4,2},{1,3},{2,3},{3,3},{2,4}}
for _,p in ipairs(hb) do local u = 0.3 + p[1]*0.06; local v = -0.6 + p[2]*0.28; mk(7, {{u,v},{u+0.03,v}}, pink, 7, {1,1}) end
for k=0,9 do local u = -0.85 + (k%5)*0.12; local v = -0.5 + (k//5)*0.5; mk(7, {{u,v},{u+0.04,v}}, navy, 6, {1,1}) end
-- 8 window chrome: title bar, buttons, scrollbar
mk(8, {{-0.9,-0.75},{0.9,-0.75}}, blue, 8, {1,1})
for k=0,2 do mk(8, {{0.6+k*0.1,-0.75},{0.63+k*0.1,-0.75}}, (k==2) and redp or pink, 5, {1,1}) end
mk(8, {{0.88,-0.5},{0.88,0.8}}, navy, 3, {0.8,0.8}); mk(8, {{0.88,-0.2},{0.88,0.1}}, blue, 4, {1,1})
-- 9 loading: progress bar and the swirl
mk(9, {{-0.8,0.45},{0.6,0.45}}, navy, 6, {1,1}); mk(9, {{-0.8,0.45},{-0.05,0.45}}, orng, 5, {1,1})
local c = PT(9,-0.45,-0.2)
local sw = brush{kind="round", width=4, point=0.8}; sw:load(orng, 1.0)
local pts = {}; for a=0,40 do local t = a/40*2.6*math.pi; local r = 2 + a*0.75; pts[#pts+1] = {c[1]+math.cos(t)*r, c[2]+math.sin(t)*r*0.45} end
sw:stroke(pts, {pressure={0.3,1.0}})
-- 10 warm: soft dotted lines like handwriting
for r=-1,1 do for k=0,10 do local u = -0.8 + k*0.15 + rand(-0.02,0.02); mk(10, {{u,r*0.4},{u+0.06,r*0.4+rand(-0.05,0.05)}}, orng, 2, {0.7,0.3}) end end

--@ chunk 5
print(wait(24*60))
local hotw = pile{{"zinc white",4},{"lemon chrome",0.1}}
local warm = pile{{"zinc white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}
for i=1,10 do
  local L = LY[i]
  local a = {L.cx-L.w-L.s, L.y+L.d}; local b = {L.cx+L.w-L.s, L.y+L.d}; local c = {L.cx+L.w+L.s, L.y-L.d}
  -- the slab's thickness under its front edge, a deeper tone of its own colour
  local t = {}; for _,x in ipairs(LC[i]) do t[#t+1] = {x[1], x[1]=="zinc white" and 1.2 or x[2]*1.6} end
  t[#t+1] = {"ultramarine blue",0.3}
  local side = poly({a, b, {b[1],b[2]+7}, {a[1],a[2]+7}}) - hole(i):grow(2)
  work(side, {hand="detail", pile=pile(t), coverage=3, fill=true, angle=0})
  -- glassy edges: bright where they face the shaft, fading to the corners
  local br = brush{kind="round", width=2.2, point=0.8}
  br:load(hotw, 0.9); br:stroke({a, {SHX-40,a[2]}, b}, {pressure={0.15,0.9,0.15}, swell={0.3,1,1.3,1,0.3}, ramps={0.1,0.1}, clip=-hole(i):grow(1)})
  br:load(hotw, 0.7); br:stroke({b, c}, {pressure={0.5,0.2}, ramps={0.1,0.2}})
  br:load(hotw, 0.5); br:stroke({c, {L.cx-L.w+L.s, L.y-L.d}}, {pressure={0.25,0.15}, ramps={0.1,0.2}})
  -- the torn hole: warm light catching its ragged lip
  local lip = hole(i):grow(5) - hole(i)
  work(lip * slab(i), {hand="detail", pile=warm, coverage=2.5, fill=true})
end
-- shards of the collapsed layers falling down the shaft
for k=1,26 do
  local i = math.random(1,10)
  local x = SHX + rand(-26,26); local y = rand(120,1060)
  local s = rand(4,9)
  local t = {}; for _,q in ipairs(LC[i]) do t[#t+1] = q end
  work(poly({{x-s,y-s*0.3},{x+s*0.7,y-s*0.6},{x+s,y+s*0.3},{x-s*0.6,y+s*0.5}}), {hand="detail", pile=pile(t), coverage=3, fill=true})
end

--@ chunk 6
local hotw = pile{{"zinc white",4},{"lemon chrome",0.12}}
local warm = pile{{"zinc white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}
local peach = pile{{"zinc white",2},{"Mars orange",0.3},{"rose madder",0.2}}
work(ellipse(SHX,1140,150,62):roughen(6,40,3) - slab(10), {hand="body", tool="filbert 6", pile=peach, coverage=2.6, fill=true, angle=0, length={14,40}, edge="soft"})
work(ellipse(SHX,1140,95,42):roughen(5,30,4) - slab(10), {hand="body", tool="filbert 5", pile=warm, coverage=2.8, fill=true, angle=0, length={10,30}, edge="soft"})
work(ellipse(SHX,1140,55,26) - slab(10), {hand="body", tool="filbert 4", pile=hotw, coverage=3, fill=true, angle=0, length={8,20}, edge="soft"})
print(wait(2*24*60))
-- the thing itself: her avatar, small, waving
local hair = pile{{"bone black",2},{"ultramarine blue",1}}
local skin = pile{{"zinc white",3},{"rose madder",0.15},{"Mars orange",0.1}}
local wht = pile{{"zinc white",4},{"cerulean blue",0.05}}
local red = pile{{"vermilion",1},{"cadmium red",0.5}}
local org = pile{{"cadmium yellow",1},{"Mars orange",1}}
local X = SHX
work(poly({{X-14,1092},{X,1086},{X+14,1092},{X+22,1110},{X+24,1160},{X+16,1168},{X+10,1150},{X-10,1150},{X-16,1168},{X-24,1160},{X-22,1110}}), {hand="detail", pile=hair, coverage=3.5, fill=true, angle=1.57})
work(poly({{X-11,1104},{X+11,1104},{X+12,1118},{X,1128},{X-12,1118}}), {hand="detail", pile=skin, coverage=3.5, fill=true})
work(poly({{X-12,1096},{X+12,1096},{X+13,1106},{X-13,1106}}), {hand="detail", pile=hair, coverage=3.5, fill=true})
work(poly({{X-9,1132},{X+9,1132},{X+11,1152},{X-11,1152}}), {hand="detail", pile=wht, coverage=3.5, fill=true})
work(poly({{X-11,1150},{X+11,1150},{X+11,1154},{X-11,1154}}), {hand="detail", pile=org, coverage=3, fill=true})
work(poly({{X-3,1128},{X+3,1128},{X+3,1132},{X-3,1132}}), {hand="detail", pile=skin, coverage=3, fill=true})
local lg = brush{kind="round", width=2.6, point=0.3}
lg:load(skin, 1.0); lg:stroke({{X-5,1154},{X-5,1166}}, {pressure={1,1}}); lg:stroke({{X+5,1154},{X+5,1166}}, {pressure={1,1}})
lg:load(skin, 1.0); lg:stroke({{X+10,1136},{X+18,1124},{X+20,1114}}, {pressure={1,0.9}})
stipple(ellipse(X+20,1112,3,3), {pile=skin, width=2.5, coverage=3})
work(poly({{X-9,1165},{X-2,1165},{X-2,1170},{X-10,1170}}) + poly({{X+2,1165},{X+9,1165},{X+10,1170},{X+2,1170}}), {hand="detail", pile=red, coverage=3.5, fill=true})
local eb = pile{{"cobalt blue",1},{"ultramarine blue",1}}
stipple(ellipse(X-5,1113,2,2.4), {pile=eb, width=2, coverage=3}); stipple(ellipse(X+5,1113,2,2.4), {pile=eb, width=2, coverage=3})
stipple(ellipse(X-4.4,1112,0.7,0.7), {pile=wht, width=1, coverage=2}); stipple(ellipse(X+5.6,1112,0.7,0.7), {pile=wht, width=1, coverage=2})
stipple(ellipse(X,1121,1,0.8), {pile=red, width=1, coverage=2})

--@ chunk 7
print(wait(8*24*60))
print(drying(SHX,1140))
local hotw = pile{{"zinc white",4},{"lemon chrome",0.12}}
-- the thing itself: her avatar, small, waving
local hair = pile{{"bone black",2},{"ultramarine blue",1}}
local skin = pile{{"zinc white",3},{"rose madder",0.15},{"Mars orange",0.1}}
local wht = pile{{"zinc white",4},{"cerulean blue",0.05}}
local red = pile{{"vermilion",1},{"cadmium red",0.5}}
local org = pile{{"cadmium yellow",1},{"Mars orange",1}}
local X = SHX
work(poly({{X-14,1092},{X,1086},{X+14,1092},{X+22,1110},{X+24,1160},{X+16,1168},{X+10,1150},{X-10,1150},{X-16,1168},{X-24,1160},{X-22,1110}}), {hand="body", tool="round 2", pile=hair, coverage=5, length={4,10}, clip=true, fill=true, angle=1.57})
work(poly({{X-11,1104},{X+11,1104},{X+12,1118},{X,1128},{X-12,1118}}), {hand="body", tool="round 2", pile=skin, coverage=5, length={3,8}, clip=true, fill=true})
work(poly({{X-12,1096},{X+12,1096},{X+13,1106},{X-13,1106}}), {hand="body", tool="round 2", pile=hair, coverage=5, length={4,10}, clip=true, fill=true})
work(poly({{X-9,1132},{X+9,1132},{X+11,1152},{X-11,1152}}), {hand="body", tool="round 2", pile=wht, coverage=5, length={3,8}, clip=true, fill=true})
work(poly({{X-11,1150},{X+11,1150},{X+11,1154},{X-11,1154}}), {hand="detail", pile=org, coverage=3, fill=true})
work(poly({{X-3,1128},{X+3,1128},{X+3,1132},{X-3,1132}}), {hand="detail", pile=skin, coverage=3, fill=true})
local lg = brush{kind="round", width=2.6, point=0.3}
lg:load(skin, 1.0); lg:stroke({{X-5,1154},{X-5,1166}}, {pressure={1,1}}); lg:stroke({{X+5,1154},{X+5,1166}}, {pressure={1,1}})
lg:load(skin, 1.0); lg:stroke({{X+10,1136},{X+18,1124},{X+20,1114}}, {pressure={1,0.9}})
stipple(ellipse(X+20,1112,3,3), {pile=skin, width=2.5, coverage=3})
work(poly({{X-9,1165},{X-2,1165},{X-2,1170},{X-10,1170}}) + poly({{X+2,1165},{X+9,1165},{X+10,1170},{X+2,1170}}), {hand="body", tool="round 2", pile=red, coverage=5, length={3,8}, clip=true, fill=true})
local eb = pile{{"cobalt blue",1},{"ultramarine blue",1}}
stipple(ellipse(X-5,1113,2,2.4), {pile=eb, width=2, coverage=3}); stipple(ellipse(X+5,1113,2,2.4), {pile=eb, width=2, coverage=3})
stipple(ellipse(X-4.4,1112,0.7,0.7), {pile=wht, width=1, coverage=2}); stipple(ellipse(X+5.6,1112,0.7,0.7), {pile=wht, width=1, coverage=2})
stipple(ellipse(X,1121,1,0.8), {pile=red, width=1, coverage=2})

--@ chunk 8
print(wait(2*24*60))
local X = SHX
local skin = pile{{"lead white",3},{"rose madder",0.12},{"Mars orange",0.08}}
local wht = pile{{"lead white",2},{"zinc white",2},{"cerulean blue",0.04}}
local red = pile{{"vermilion",1},{"cadmium red",0.5}}
local function f(m, p) work(m, {hand="body", tool="round 2", pile=p, coverage=6, fill=true, clip=true, length={3,8}, load=1.0}) end
f(poly({{X-11,1105},{X+11,1105},{X+12,1118},{X,1128},{X-12,1118}}), skin)
f(poly({{X-9,1132},{X+9,1132},{X+11,1150},{X-11,1150}}), wht)
f(poly({{X-3,1127},{X+3,1127},{X+3,1132},{X-3,1132}}), skin)
local lg = brush{kind="round", width=2.8, point=0.3}
lg:load(skin, 1.0); lg:stroke({{X+10,1136},{X+19,1124},{X+21,1112}}, {pressure={1,0.9}})
lg:load(skin, 1.0); lg:stroke({{X+19,1115},{X+23,1110}}, {pressure={1,1}})
lg:load(skin, 1.0); lg:stroke({{X-5,1155},{X-5,1165}}, {pressure={1,1}}); lg:load(skin, 1.0); lg:stroke({{X+5,1155},{X+5,1165}}, {pressure={1,1}})
local eb = pile{{"ultramarine blue",1},{"bone black",0.5}}
for _,e in ipairs({-5,5}) do
  work(poly({{X+e-2.6,1110},{X+e+2.6,1110},{X+e+2.6,1116},{X+e-2.6,1116}}), {hand="body", tool="round 1.2", pile=eb, coverage=6, fill=true, clip=true, length={2,4}})
  stipple(ellipse(X+e+0.8,1111.5,0.7,0.7), {pile=wht, width=1, coverage=3})
end
stipple(ellipse(X,1122,1.2,0.8), {pile=red, width=1.2, coverage=3})
local blush = pile{{"lead white",1},{"rose madder",0.5}}
stipple(ellipse(X-8,1119,1.5,1), {pile=blush, width=1.4, coverage=2}); stipple(ellipse(X+8,1119,1.5,1), {pile=blush, width=1.4, coverage=2})

--@ chunk 9
local S = slab(1); for i=2,10 do S = S + slab(i) end
STACK = S
local deep = pile{{"ultramarine blue",2},{"bone black",1.4},{"cobalt violet",0.5}}
local mid = pile{{"ultramarine blue",2},{"bone black",0.6},{"cobalt violet",0.6},{"zinc white",0.4}}
local disc = ellipse(SHX,1140,160,68)
local far = -(ellipse(SHX,700,430,620):soften(80)) - S:grow(2) - disc
work(far, {hand="body", tool="filbert 12", pile=deep, coverage=2.6, fill=true, clip=-(S:grow(2)+disc), angle=1.57, length={40,120}})
-- light leaking from the shaft in the gaps between the layers
local leak = pile{{"zinc white",2},{"Indian yellow",0.4},{"cobalt violet",0.2}, medium=0.4}
for i=1,9 do
  local y0 = LY[i].y + LY[i].d + 8; local y1 = LY[i+1].y - LY[i+1].d
  if y1 > y0 then
    local m = ellipse(SHX, (y0+y1)/2, 70, (y1-y0)*0.7):soften(10) - S:grow(1)
    work(m, {hand="body", tool="filbert 4", pile=leak, coverage=1.6, clip=-(S:grow(1)), angle=0, length={8,24}, load=0.6})
  end
end
-- the wave
local skin = pile{{"lead white",3},{"rose madder",0.12},{"Mars orange",0.08}}
local lg = brush{kind="round", width=3, point=0.3}
lg:load(skin, 1.0); lg:stroke({{SHX+11,1134},{SHX+27,1126},{SHX+30,1110}}, {pressure={1,0.9}})
stipple(ellipse(SHX+30,1106,3.2,3.2), {pile=skin, width=2.5, coverage=4})

--@ chunk 10
local wg = pile{{"lead white",2},{"zinc white",1},{"Indian yellow",0.5},{"Mars orange",0.15}}
for i=1,10 do
  local L = LY[i]
  local m = (ellipse(SHX, L.y, 130 - i*3, L.d*0.95):soften(20) - hole(i):grow(5)) * slab(i)
  work(m, {hand="scumble", tool="filbert 5", pile=wg, coverage=1.2, clip=slab(i) - hole(i):grow(4), angle=0, load=0.55})
end
-- the warm light at the bottom, radiating instead of ringed
local rays = pile{{"lead white",2},{"Indian yellow",0.5},{"rose madder",0.2}}
local b = brush{kind="filbert", width=4, point=0.5}
for k=0,35 do
  local a = k/36*2*math.pi + rand(-0.05,0.05)
  local r0, r1 = rand(20,40), rand(110,175)
  local x0, y0 = SHX + math.cos(a)*r0, 1140 + math.sin(a)*r0*0.42
  local x1, y1 = SHX + math.cos(a)*r1, 1140 + math.sin(a)*r1*0.42
  if y1 > 1085 or math.abs(x1-SHX) > 120 then
    b:load(rays, 0.7)
    b:stroke({{x0,y0},{x1,y1}}, {pressure={0.7,0.0}, ramps={0.1,0.6}, clip=-(STACK:grow(1) + rect(SHX-26,1084,52,90))})
  end
end

--@ chunk 11
for i=1,10 do
  local L = LY[i]
  local m = (ellipse(SHX, L.y, 165 - i*3, L.d*0.98) - ellipse(SHX, L.y, 70, L.d*0.5) - hole(i):grow(6)) * slab(i):shrink(3)
  blend(m, {clip=true, angle=0})
end

--@ chunk 12
print(wait(2*24*60))
local hotw = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.1}}
local col = rect(SHX-22, 35, 44, 1050):roughen(3,20,9)
work(col - STACK:shrink(0) + (function() local h = hole(1); for i=2,10 do h = h + hole(i) end; return h end)() * col:grow(8),
  {hand="body", tool="filbert 4", pile=hotw, coverage=3, fill=true, clip=true, angle=1.57, length={20,60}})
-- the layers' content carrying faintly across the light: they are translucent, the light is under them
local pb = pile{{"cerulean blue",1},{"zinc white",1.5}, medium=0.3}
local function mk2(i, u0, u1, v, w)
  local a = PT(i,u0,v); local b = PT(i,u1,v)
  local br = brush{kind="round", width=w, point=0.5}; br:load(pb, 0.6)
  br:stroke({a,b}, {pressure={0.6,0.6}, clip=slab(i) - hole(i):grow(3)})
end
mk2(1, -0.3, 0.3, -0.1, 5); mk2(1, -0.3, 0.3, 0.45, 2)
for k=-3,3 do mk2(3, -0.3, 0.3, k*0.25, 1.8) end
for k=0,10 do mk2(4, -0.3, 0.3, -0.92 + k*0.17, 1.5) end
for k=-3,3 do mk2(5, -0.3, 0.3, k*0.28, 1.6) end
for r=-2,2 do mk2(6, -0.25, 0.25, r*0.32, 1.8) end

--@ chunk 13
-- PASS / 1: each layer repainted in its own colour, like different software
print(wait(3*24*60))
LC2 = {
 {{"lead white",2},{"cerulean blue",1},{"emerald green",0.15}},       -- 1 status: cyan
 {{"lead white",2},{"cobalt blue",0.8},{"ultramarine ash",0.4}},      -- 2 dashboard: steel blue
 {{"lead white",2},{"emerald green",0.7},{"lemon chrome",0.2}},       -- 3 ledger: mint green
 {{"lead white",1.5},{"viridian",0.8},{"cerulean blue",0.4}},         -- 4 scanlines: CRT teal
 {{"lead white",2},{"cobalt violet",1.2},{"ultramarine blue",0.2}},   -- 5 wireframe: lavender
 {{"lead white",2},{"magenta",0.35},{"rose madder",0.3}},             -- 6 caveats: pink
 {{"lead white",2},{"lemon chrome",0.8},{"chrome yellow",0.2}},       -- 7 VMU: lemon
 {{"lead white",2},{"cerulean blue",0.6},{"cobalt violet",0.3}},      -- 8 window: periwinkle
 {{"lead white",2},{"chrome yellow",0.6},{"Mars orange",0.4}},        -- 9 loading: amber
 {{"lead white",2},{"vermilion",0.3},{"Mars orange",0.3}},            -- 10 warm: coral
}
LP2 = {}
for i=10,1,-1 do
  local t = {}; for _,c in ipairs(LC2[i]) do t[#t+1] = c end; t.medium = 0.15
  LP2[i] = pile(t)
  work(slab(i):shrink(1) - hole(i):grow(3), {hand="body", tool="filbert 6", pile=LP2[i], coverage=3, fill=true, clip=true, angle=0.0, length={20,60}, load=1.0})
end

--@ chunk 14
-- PASS / 2: each surface's marks drawn again on the new colours
print(wait(3*24*60))
function PT(i,u,v) local L = LY[i]; return {L.cx + u*L.w - v*L.s, L.y + v*L.d} end
function mk(i, pts, p, width, pr, load)
  local b = brush{kind="round", width=(width or 2)*2.0, point=0.5}
  b:load(p, 1.0)
  local q = {}; for _,t in ipairs(pts) do q[#q+1] = PT(i,t[1],t[2]) end
  b:stroke(q, {pressure={1.0,1.0}, ramps={0.05,0.1}, clip=slab(i) - hole(i)})
end
navy = pile{{"ultramarine blue",2},{"bone black",0.6},{"zinc white",0.3}}
orng = pile{{"Mars orange",1},{"cadmium yellow",1},{"zinc white",0.5}}
cyan = pile{{"cerulean blue",1},{"zinc white",1},{"emerald green",0.2}}
pink = pile{{"magenta",1},{"zinc white",1}}
redp = pile{{"vermilion",1},{"cadmium red",0.5}}
blue = pile{{"cobalt blue",1},{"zinc white",0.4}}
-- 1 status summary bar: segments and three chips
for k=0,5 do local u0 = -0.85 + k*0.22; mk(1, {{u0,-0.1},{u0+0.15,-0.1}}, navy, 6, {0.9,0.9}) end
mk(1, {{0.62,-0.1},{0.66,-0.1}}, orng, 7, {1,1}); mk(1, {{0.72,-0.1},{0.76,-0.1}}, blue, 7, {1,1}); mk(1, {{0.82,-0.1},{0.86,-0.1}}, blue, 7, {1,1})
mk(1, {{-0.9,0.45},{0.9,0.45}}, navy, 1.5, {0.5,0.5})
-- 2 dashboard: dials with needles
for k,u in ipairs({-0.6,-0.1,0.45}) do
  local c = PT(2,u,0)
  local b = brush{kind="round", width=2, point=0.6}; b:load(navy, 0.8)
  local pts = {}; for a=0,32 do local t = a/32*2*math.pi; pts[#pts+1] = {c[1]+math.cos(t)*44, c[2]+math.sin(t)*20} end
  b:stroke(pts, {pressure={0.6,0.6}})
  local nb = brush{kind="round", width=2.5, point=0.8}; nb:load(k==2 and redp or orng, 0.9)
  nb:stroke({c, {c[1]+math.cos(-0.6-k*0.5)*36, c[2]+math.sin(-0.6-k*0.5)*16}}, {pressure={0.9,0.3}})
end
-- 3 ledger: ruled lines, column rules, entries
for k=-3,3 do mk(3, {{-0.9,k*0.25},{0.9,k*0.25}}, blue, 1.2, {0.4,0.4}, 0.6) end
for _,u in ipairs({-0.5,0.35,0.65}) do mk(3, {{u,-0.85},{u,0.85}}, redp, 1.2, {0.4,0.4}, 0.6) end
for k=-3,2 do mk(3, {{-0.45,k*0.25+0.12},{-0.45+rand(0.2,0.6),k*0.25+0.12}}, navy, 1.6, {0.6,0.5}); mk(3, {{0.4,k*0.25+0.12},{0.58,k*0.25+0.12}}, navy, 1.6, {0.6,0.5}) end
-- 4 scanline field
for k=0,22 do local v = -0.92 + k*0.084; mk(4, {{-1,v},{1,v}}, (k%2==0) and cyan or navy, 1.3, {0.35,0.35}, 0.5) end
-- 5 wireframe grid, a low-poly lattice
for k=-4,4 do mk(5, {{k*0.22,-1},{k*0.22,1}}, cyan, 1.5, {0.5,0.5}) end
for k=-3,3 do mk(5, {{-1,k*0.28},{1,k*0.28}}, cyan, 1.5, {0.5,0.5}) end
for k=-3,2 do mk(5, {{k*0.22-0.1,-0.84},{k*0.22+0.34,0.84}}, pink, 1.2, {0.4,0.4}, 0.6) end
-- 6 caveats: footnote marks and small print
for r=-2,2 do
  mk(6, {{-0.8,r*0.32},{-0.78,r*0.32}}, redp, 4, {1,1})
  local u = -0.7
  while u < 0.8 do local l = rand(0.05,0.18); mk(6, {{u,r*0.32},{u+l,r*0.32}}, navy, 1.6, {0.6,0.6}); u = u + l + 0.04 end
end
-- 7 VMU pixels: a little blocky heart among squares
local hb = {{0,0},{1,0},{3,0},{4,0},{-1,1},{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{0,2},{1,2},{2,2},{3,2},{4,2},{1,3},{2,3},{3,3},{2,4}}
for _,p in ipairs(hb) do local u = 0.3 + p[1]*0.06; local v = -0.6 + p[2]*0.28; mk(7, {{u,v},{u+0.03,v}}, pink, 7, {1,1}) end
for k=0,9 do local u = -0.85 + (k%5)*0.12; local v = -0.5 + (k//5)*0.5; mk(7, {{u,v},{u+0.04,v}}, navy, 6, {1,1}) end
-- 8 window chrome: title bar, buttons, scrollbar
mk(8, {{-0.9,-0.75},{0.9,-0.75}}, blue, 8, {1,1})
for k=0,2 do mk(8, {{0.6+k*0.1,-0.75},{0.63+k*0.1,-0.75}}, (k==2) and redp or pink, 5, {1,1}) end
mk(8, {{0.88,-0.5},{0.88,0.8}}, navy, 3, {0.8,0.8}); mk(8, {{0.88,-0.2},{0.88,0.1}}, blue, 4, {1,1})
-- 9 loading: progress bar and the swirl
mk(9, {{-0.8,0.45},{0.6,0.45}}, navy, 6, {1,1}); mk(9, {{-0.8,0.45},{-0.05,0.45}}, orng, 5, {1,1})
local c = PT(9,-0.45,-0.2)
local sw = brush{kind="round", width=4, point=0.8}; sw:load(orng, 1.0)
local pts = {}; for a=0,40 do local t = a/40*2.6*math.pi; local r = 2 + a*0.75; pts[#pts+1] = {c[1]+math.cos(t)*r, c[2]+math.sin(t)*r*0.45} end
sw:stroke(pts, {pressure={0.3,1.0}})
-- 10 warm: soft dotted lines like handwriting
for r=-1,1 do for k=0,10 do local u = -0.8 + k*0.15 + rand(-0.02,0.02); mk(10, {{u,r*0.4},{u+0.06,r*0.4+rand(-0.05,0.05)}}, orng, 2, {0.7,0.3}) end end

--@ chunk 15
-- PASS / 3: the shaft's light falling on each layer: short graded strokes from the torn edge outward
print(wait(3*24*60))
local warmL = pile{{"lead white",2},{"zinc white",1},{"Indian yellow",0.35},{"Mars orange",0.05}, medium=0.35}
local hotL = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.12}, medium=0.2}
for i=1,10 do
  local L = LY[i]
  local r = 34 + i*1.5; local ry = r*L.d/90
  local clipm = slab(i) - hole(i):grow(1)
  local b = brush{kind="filbert", width=3, point=0.5}
  local function ray(R, p, load, pmax, n)
    for k=1,n do
      local a = rand(0, 2*math.pi)
      local f = rand(0.55, 1.0)
      local x0, y0 = SHX + math.cos(a)*r*1.02, L.y + math.sin(a)*ry*1.02
      local x1, y1 = SHX + math.cos(a)*r*R*f, L.y + math.sin(a)*ry*R*f
      b:load(p, load)
      b:stroke({{x0,y0},{(x0+x1)/2,(y0+y1)/2},{x1,y1}}, {pressure={pmax,0.0}, ramps={0.02,0.75}, clip=clipm})
    end
  end
  ray(2.7, warmL, 0.55, 0.7, 60)
  ray(1.7, hotL, 0.7, 0.9, 40)
  -- a clean brush dragged outward along the radius softens the light into the layer
  local c = brush{kind="filbert", width=4, point=0.4}
  for k=1,36 do
    local a = k/36*2*math.pi
    c:wipe(1.0)
    c:stroke({{SHX + math.cos(a)*r*1.05, L.y + math.sin(a)*ry*1.05}, {SHX + math.cos(a)*r*2.4, L.y + math.sin(a)*ry*2.4}}, {pressure={0.5,0.2}, clip=clipm})
  end
end

--@ chunk 16
-- PASS / 4: torn edges bright and sharp; her ring of light warmer
print(wait(2*24*60))
local hotw = pile{{"zinc white",4},{"lead white",1},{"lemon chrome",0.1}}
local rg = brush{kind="rigger", width=1.8, point=1}
for i=1,10 do
  local L = LY[i]
  local r = 34 + i*1.5; local ry = r*L.d/90
  local pts = {}
  for k=0,24 do
    local a = math.pi*(0.0 + k/24)          -- the front lip, nearest us
    local j = 1 + rand(-0.08, 0.08)
    pts[#pts+1] = {SHX + math.cos(a)*r*j, L.y + math.sin(a)*ry*j}
  end
  rg:load(hotw, 1.0); rg:stroke(pts, {pressure={0.6,0.9}, swell={0.4,1,1.2,1,0.4}, ramps={0.05,0.1}})
  local back = {}
  for k=0,16 do local a = math.pi*(1.0 + k/16); local j = 1 + rand(-0.06,0.06); back[#back+1] = {SHX + math.cos(a)*r*j, L.y + math.sin(a)*ry*j} end
  rg:load(hotw, 0.8); rg:stroke(back, {pressure={0.3,0.5}, ramps={0.1,0.1}})
  for t=1,4 do local a = rand(0,math.pi); local x, y = SHX + math.cos(a)*r, L.y + math.sin(a)*ry
    rg:load(hotw, 0.9); rg:stroke({{x,y},{x+math.cos(a)*rand(4,9), y+math.sin(a)*rand(2,5)}}, {pressure={0.8,0.1}}) end
end
-- her ring: warm the lilac and pink into amber and rose, keep her clear
local amber = pile{{"lead white",2},{"Indian yellow",0.8},{"Mars orange",0.4},{"rose madder",0.1}}
local rose = pile{{"lead white",2},{"Mars orange",0.5},{"rose madder",0.35},{"Indian yellow",0.3}}
local her = rect(SHX-28,1082,60,92)
local ringO = ellipse(SHX,1140,162,70) - ellipse(SHX,1140,105,46) - STACK:grow(1)
local ringI = ellipse(SHX,1140,108,48) - ellipse(SHX,1140,58,28) - STACK:grow(1) - her
work(ringO, {hand="body", tool="filbert 5", pile=rose, coverage=2.6, fill=true, clip=-(STACK:grow(1)+her), angle=0, length={14,40}, edge="soft"})
work(ringI, {hand="body", tool="filbert 4", pile=amber, coverage=2.6, fill=true, clip=-(STACK:grow(1)+her), angle=0, length={10,30}, edge="soft"})
local rays = pile{{"lead white",2},{"Indian yellow",0.6},{"zinc white",1}}
local b = brush{kind="filbert", width=3, point=0.5}
for k=0,47 do
  local a = k/48*2*math.pi + rand(-0.04,0.04)
  local r0, r1 = rand(30,50), rand(120,180)
  b:load(rays, 0.7)
  b:stroke({{SHX + math.cos(a)*r0, 1140 + math.sin(a)*r0*0.43}, {SHX + math.cos(a)*r1, 1140 + math.sin(a)*r1*0.43}}, {pressure={0.8,0.0}, ramps={0.05,0.7}, clip=-(STACK:grow(1)+her)})
end

--@ chunk 17
-- PASS / 5: a softer, wider fall of warm light under the bright rays
print(wait(24*60))
local haze = pile{{"lead white",1.5},{"zinc white",1},{"Indian yellow",0.4},{"Mars orange",0.08}, medium=0.6}
for i=1,10 do
  local L = LY[i]
  local r = 34 + i*1.5; local ry = r*L.d/90
  local clipm = slab(i) - hole(i):grow(1)
  local b = brush{kind="filbert", width=6, point=0.3}
  for k=1,70 do
    local a = rand(0, 2*math.pi); local f = rand(0.6,1.0)
    local x0, y0 = SHX + math.cos(a)*r*1.05, L.y + math.sin(a)*ry*1.05
    local x1, y1 = SHX + math.cos(a)*r*3.6*f, L.y + math.sin(a)*ry*3.6*f
    b:load(haze, 0.35)
    b:stroke({{x0,y0},{x1,y1}}, {pressure={0.45,0.0}, ramps={0.02,0.85}, clip=clipm})
  end
end
