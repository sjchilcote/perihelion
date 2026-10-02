-- easel session "endpapers": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=2, linen={18,16}, seed=4040, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.12}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
-- the diagonal repeat: same motif along each diagonal; masks gathered per colour, one pass per colour
POS = {}
for r=0,3 do for c=-1,6 do
  local x, y = 75 + c*170 + r*85, 68 + r*122
  if x > 40 and x < 960 then POS[#POS+1] = {x=x, y=y, t=((c - r) % 6)} end
end end
M = {}
local function add(k, m) M[k] = M[k] and (M[k] + m) or m end
local function P(p) return poly(p) end
for _,q in ipairs(POS) do
  local x, y = q.x, q.y
  if q.t == 0 then -- a little knight waving
    local helm = ellipse(x, y-24, 15, 14); local body = poly({{x-17,y-10},{x+17,y-10},{x+19,y+26},{x-19,y+26}}, true)
    local arm = poly({{x+14,y-6},{x+26,y-26},{x+31,y-24},{x+20,y}})
    local tab = poly({{x-11,y-8},{x+11,y-8},{x+12,y+24},{x-12,y+24}}); local cross = rect(x-2,y-4,4,18) + rect(x-7,y+1,14,4)
    local visor = poly({{x-14,y-28},{x+14,y-28},{x+14,y-21},{x-14,y-21}}); local dot = ellipse(x-6,y-24.5,2.6,2.6)
    add("grey", helm + body + arm + ellipse(x+31,y-27,4.5,4.5) - tab - visor); add("red", tab - cross); add("bone", cross)
    add("ink", visor - dot); add("light", dot)
  elseif q.t == 1 then -- a tiny Ratio
    local face = rect(x-8,y-26,16,15); local hair = poly({{x-12,y-30},{x+12,y-30},{x+13,y+4},{x-13,y+4}}, true) + ellipse(x,y-28,12,9)
    local dress = poly({{x-9,y-10},{x+9,y-10},{x+11,y+14},{x-11,y+14}}); local arm = poly({{x+8,y-8},{x+17,y-22},{x+21,y-20},{x+12,y-4}})
    add("ink", hair - face - dress - arm); add("skin", face + ellipse(x+19,y-24,3.5,3.5)); add("white", dress + arm); add("tan", rect(x-7,y+14,5,9) + rect(x+2,y+14,5,9))
  elseif q.t == 2 then -- a curled sleepy bug
    local body = ellipse(x, y+6, 36, 20) + ellipse(x-32, y+10, 13, 11)
    add("purple", body)
    for k=0,4 do local a = math.pi*(1.15 + 0.7*k/4); local px, py = x + 34*math.cos(a), y+6 + 18*math.sin(a)
      add("blue", poly({{px-6,py+4},{px + 13*math.cos(a), py + 13*math.sin(a)},{px+6,py+4}}) - body) end
  elseif q.t == 3 then -- a little sun
    local disc = ellipse(x, y, 20, 20); add("sun", disc)
    for k=0,7 do local a = k*math.pi/4; add("ray", poly({{x + 24*math.cos(a+0.18), y + 24*math.sin(a+0.18)},{x + 36*math.cos(a), y + 36*math.sin(a)},{x + 24*math.cos(a-0.18), y + 24*math.sin(a-0.18)}})) end
  elseif q.t == 4 then -- a little gold ring
    add("gold", ellipse(x, y, 32, 14) - ellipse(x, y-1, 24, 8))
  else -- stars
    for _,s in ipairs({{0,0,12},{-30,18,7},{26,-16,6}}) do local sx, sy, r = x+s[1], y+s[2], s[3]
      add("gold", poly({{sx,sy-r},{sx+r*0.3,sy-r*0.3},{sx+r,sy},{sx+r*0.3,sy+r*0.3},{sx,sy+r},{sx-r*0.3,sy+r*0.3},{sx-r,sy},{sx-r*0.3,sy-r*0.3}})) end
  end
end
PILES = {
  grey = pile{{"lead white",1.2},{"ultramarine ash",0.5},{"yellow ochre",0.4},{"burnt sienna",0.12}},
  red = pile{{"cadmium red",1},{"Mars red",0.6}}, bone = pile{{"lead white",2.2},{"yellow ochre",0.4}},
  ink = pile{{"bone black",2},{"ultramarine blue",0.3}}, light = pile{{"lead white",2.5},{"cadmium yellow",0.5}},
  skin = pile{{"lead white",2.8},{"rose madder",0.15},{"yellow ochre",0.1}}, white = pile{{"zinc white",2.8}},
  tan = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}},
  purple = pile{{"cobalt violet",1},{"magenta",0.35},{"lead white",0.7}}, blue = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"lead white",0.3}},
  sun = pile{{"cadmium yellow",1.2},{"Mars orange",0.5},{"lead white",0.5}}, ray = pile{{"Mars orange",1},{"cadmium yellow",0.6}},
  gold = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",0.3}},
}
for _,k in ipairs({"grey","red","bone","ink","light","skin","white","tan","purple","blue","sun","ray","gold"}) do
  if M[k] then work(M[k], {hand="detail", pile=PILES[k], coverage=7, fill=true, clip=M[k], load=1}) end
end
print(#POS)

--@ chunk 3
print(wait(4*24*60))
work(M.grey, {hand="detail", pile=pile{{"lead white",1},{"ultramarine ash",0.7},{"yellow ochre",0.3},{"burnt sienna",0.15},{"bone black",0.08}}, coverage=7, fill=true, clip=M.grey, load=1})
local r = brush{kind="round", width=2.5, point=0.8}
local INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
for _,q in ipairs(POS) do
  local x, y = q.x, q.y
  if q.t == 1 then
    r:reload(INK, 0.8); r:touch(x-3.5, y-20, {pressure=0.5}); r:reload(INK, 0.8); r:touch(x+3.5, y-20, {pressure=0.5})
    r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.6); r:stroke({{x-2.5,y-15},{x,y-13.5},{x+2.5,y-15}}, {pressure={r:pressure_for(1), r:pressure_for(1)}})
  elseif q.t == 2 then
    r:reload(INK, 0.7); r:stroke({{x-37,y+8},{x-33,y+11},{x-29,y+8}}, {pressure={r:pressure_for(1.3), r:pressure_for(1.3)}})
    r:reload(pile{{"cobalt violet",1},{"lead white",0.6}}, 0.7); r:stroke({{x+30,y-24},{x+38,y-24},{x+30,y-16},{x+38,y-16}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
  elseif q.t == 0 then
    r:reload(INK, 0.6); r:stroke({{x+34,y-36},{x+40,y-42}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})
    r:reload(INK, 0.6); r:stroke({{x+38,y-28},{x+46,y-30}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})
  end
end
-- little dots in the gaps, and a faint gutter fold down the middle
local d = brush{kind="round", width=5, point=0}
for _,q in ipairs(POS) do d:reload(pile{{"Mars orange",0.6},{"lead white",1.2},{"yellow ochre",0.4}}, 0.5); d:touch(q.x + 85, q.y + 60, {pressure=0.6}) end
local g = brush{kind="round", width=4, point=0.5}
g:reload(pile{{"lead white",1.6},{"burnt sienna",0.3},{"yellow ochre",0.5}}, 0.5); g:stroke({{500,0},{500,500}}, {pressure={g:pressure_for(3), g:pressure_for(3)}})

--@ chunk 4
print(wait(3*24*60))
for _,q in ipairs(POS) do if q.t == 1 and math.abs(q.x - 500) < 20 then
  local x, y = q.x, q.y
  local face = rect(x-8,y-26,16,15); local hair = poly({{x-12,y-30},{x+12,y-30},{x+13,y+4},{x-13,y+4}}, true) + ellipse(x,y-28,12,9)
  local dress = poly({{x-9,y-10},{x+9,y-10},{x+11,y+14},{x-11,y+14}}); local arm = poly({{x+8,y-8},{x+17,y-22},{x+21,y-20},{x+12,y-4}})
  work(hair - face - dress - arm, {hand="detail", pile=PILES.ink, coverage=8, fill=true, clip=hair - face - dress - arm, load=1})
  work(face, {hand="detail", pile=PILES.skin, coverage=8, fill=true, clip=face, load=1})
  work(dress + arm, {hand="detail", pile=PILES.white, coverage=8, fill=true, clip=dress + arm, load=1})
  local gap = rect(x-30, 0, 60, 500) - hair - dress - arm - ellipse(x+19,y-24,4,4) - rect(x-8,y+13,17,11)
  work(gap * rect(495,0,10,500), {hand="detail", pile=pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.12}}, coverage=6, fill=true, clip=gap * rect(495,0,10,500), load=1})
  P1 = {x, y}
end end

--@ chunk 5
print(wait(3*24*60))
local r = brush{kind="round", width=2.5, point=0.8}
local x, y = P1[1], P1[2]
r:reload(PILES.ink, 0.8); r:touch(x-3.5, y-20, {pressure=0.5}); r:reload(PILES.ink, 0.8); r:touch(x+3.5, y-20, {pressure=0.5})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.6); r:stroke({{x-2.5,y-15},{x,y-13.5},{x+2.5,y-15}}, {pressure={r:pressure_for(1), r:pressure_for(1)}})

--@ chunk 6
for _,q in ipairs(POS) do if q.t == 4 then
  local m = (ellipse(q.x, q.y, 32, 14) - ellipse(q.x, q.y-1, 24, 8)) * rect(490,0,20,500)
  if m:area() > 1 then work(m, {hand="detail", pile=PILES.gold, coverage=8, fill=true, clip=m, load=1}) end
end end
