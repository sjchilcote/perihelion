-- easel session "wanderer3": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=790, aspect=0.79, linen={18,16}, seed=2626, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"raw sienna",3},{"Mars brown",2},{"lead white",2},{"ultramarine blue",0.6}}, um=30, apply="brush"}}}
G = {R=100, h=1.5, Zc=4, pitch=0.15, F=906, cx=500, cy=0}
function G.proj(X,Y,Z)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Yc=Y-G.h
  local Yp=Yc*c+Z*s; local Zp=-Yc*s+Z*c
  return G.cx+G.F*X/Zp, G.cy-G.F*Yp/Zp, Zp
end
local _,ay=G.proj(0,0,G.Zc); G.cy = 860-ay
function G.dome(r,th)
  local phi=r/G.R
  return G.R*math.sin(phi)*math.sin(th), -G.R+G.R*math.cos(phi), G.Zc+G.R*math.sin(phi)*math.cos(th)
end
function G.dp(r,th) return G.proj(G.dome(r,th)) end
G.limb={}
for xi=0,100 do G.limb[xi]=1e9 end
for ti=0,720 do local th=ti/720*2*math.pi
  for ri=1,600 do local r=ri*0.1
    local x,y,z=G.dp(r,th)
    if z>0.3 then local xi=math.floor(x/10+0.5) if xi>=0 and xi<=100 and y<G.limb[xi] then G.limb[xi]=y end end
  end end
function G.limbY(x) local xi=clamp(x/10,0,100); local a=math.floor(xi); local b=math.min(a+1,100); return lerp(G.limb[a],G.limb[b],xi-a) end
SUN={x=610,y=640,r=380}
print(W,H, G.limbY(0), G.limbY(500), G.limbY(1000))

--@ chunk 2
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local up = above(function(x) return G.limbY(x)+4 end)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local S1 = pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.5}}
local S2 = pile{{"burnt sienna",2},{"bone brown",1},{"Mars red",0.5}}
local S3 = pile{{"Mars orange",2},{"burnt sienna",1},{"red earth",0.5}}
local S4 = pile{{"cadmium yellow",1},{"Mars orange",1},{"Indian yellow",0.5},{"lead white",0.4}}
work((up - E(1.75)):roughen(20,120,3), {hand="broad", pile=S1, coverage=3, fill=true, angle=tan})
work(((E(1.8)-E(1.35))*up):roughen(18,100,4), {hand="broad", pile=S2, coverage=3, fill=true, angle=tan})
work(((E(1.4)-E(1.12))*up):roughen(12,80,5), {hand="body", pile=S3, coverage=3, fill=true, angle=tan, tool="filbert 14"})
work((E(1.15)-E(1.0))*up, {hand="body", pile=S4, coverage=3, fill=true, angle=tan, tool="filbert 10"})

--@ chunk 3
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local up = above(function(x) return G.limbY(x)+4 end)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local pc = pile{{"zinc white",4},{"lemon chrome",0.2}}
local pm = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.5},{"cadmium yellow",0.2}}
local pe = pile{{"cadmium yellow",2},{"lemon chrome",0.5},{"lead white",1.5}}
local clipD = E(1)*up
work((E(1)-E(0.86))*up, {hand="body", pile=pe, coverage=3, fill=true, angle=tan, tool="filbert 8", clip=clipD})
work((E(0.89)-E(0.66))*up, {hand="body", pile=pm, coverage=3, fill=true, angle=tan, tool="filbert 12", clip=clipD})
work(E(0.69)*up, {hand="body", pile=pc, coverage=3, fill=true, angle=tan, tool="filbert 16", clip=clipD})
work((E(0.97)-E(0.6))*up, {hand="body", pile=pm, coverage=2, angle=rad, tool="filbert 8", load=0.3, length={20,55}, clip=clipD})

--@ chunk 4
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local up = above(function(x) return G.limbY(x)+4 end)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local M12 = pile{{"burnt sienna",2},{"bone brown",1.5},{"ultramarine blue",0.5},{"Mars red",0.3}}
local M23 = pile{{"Mars orange",1.5},{"burnt sienna",1.5},{"red earth",0.4}}
local M34 = pile{{"Mars orange",1.5},{"cadmium yellow",0.8},{"Indian yellow",0.4}}
local function seam(f, w, p, tl)
  local m = ((E(f+w)-E(f-w))*up):roughen(10,60,f*10)
  work(m, {hand="body", pile=p, coverage=2.2, angle=rad, tool=tl, length={30,80}, load=0.5})
  blend(((E(f+w*0.7)-E(f-w*0.7))*up), {angle=tan, pressure={0.2,0.4}})
end
seam(1.77, 0.12, M12, "filbert 14")
seam(1.37, 0.09, M23, "filbert 12")
seam(1.13, 0.06, M34, "filbert 10")

--@ chunk 5
local L = function(x) return G.limbY(x) end
local dome = below(function(x) return L(x)-1 end)
local horiz = function(x,y) return 0.25*math.atan((x-480)/900, 1) end
local function band(a,b) return dome * below(function(x) return a + 0.0003*(x-560)^2 end) * above(function(x) return b + 0.0003*(x-560)^2 end) end
local D1 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}}
local D2 = pile{{"burnt sienna",2},{"bone black",0.8},{"yellow ochre",0.8}}
local D3 = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.4}}
local D4 = pile{{"yellow ochre",2},{"Mars orange",0.7},{"burnt sienna",0.4},{"lead white",0.5}}
local D5 = pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.6},{"yellow ochre",0.5}}
work(band(990,2000):roughen(15,90,1), {hand="broad", pile=D1, coverage=3, fill=true, angle=horiz})
work(band(860,1000):roughen(15,90,2), {hand="broad", pile=D2, coverage=3, fill=true, angle=horiz})
work(band(760,870):roughen(12,80,3), {hand="body", pile=D3, coverage=3, fill=true, angle=horiz, tool="filbert 14"})
work(band(695,770):roughen(10,70,4), {hand="body", pile=D4, coverage=3, fill=true, angle=horiz, tool="filbert 12"})
work(band(0,705), {hand="body", pile=D5, coverage=3, fill=true, angle=horiz, tool="filbert 8", clip=dome})
local glare = ellipse(610, 685, 300, 30):soften(20) * dome
work(glare, {hand="body", pile=pile{{"zinc white",3},{"lemon chrome",0.4},{"cadmium yellow",0.3}}, coverage=2.5, angle=horiz, tool="filbert 8", clip=dome})

--@ chunk 6
local L = function(x) return G.limbY(x) end
local dome = below(function(x) return L(x)-2 end)
local horiz = function(x,y) return 0.25*math.atan((x-480)/900, 1) end
local function band(a,b) return dome * below(function(x) return a + 0.0003*(x-560)^2 end) * above(function(x) return b + 0.0003*(x-560)^2 end) end
local O = pile{{"Mars orange",2},{"burnt sienna",1},{"red earth",0.4},{"yellow ochre",0.5}}
work(band(715,790):roughen(10,60,7), {hand="scumble", pile=O, coverage=1.5, angle=horiz, load=0.5})
for _,s in ipairs({{705,740},{760,790},{850,880},{980,1010}}) do
  blend(band(s[1]-12, s[2]+12), {angle=horiz, pressure={0.25,0.45}})
end

--@ chunk 7
print(wait(48*60)); print(drying(500,700), drying(500,900), drying(500,1100), drying(600,400), drying(100,100))

--@ chunk 8
print(wait(36*60))
local GA = math.pi*(3-math.sqrt(5))
local rng = noise{seed=91, octaves=1, period=3}
local function n3(X,Y,Z) return X/G.R, (Y+G.R)/G.R, (Z-G.Zc)/G.R end
PL = {}
for i=3,1900 do
  local r = 0.14*i^0.62*(1+0.03*rng(i*1.7,2))
  local th = i*GA + 0.03*rng(i*2.3,5)
  local X,Y,Z = G.dome(r,th)
  local cx,cy,cz = G.proj(X,Y,Z)
  local nx,ny,nz = n3(X,Y,Z)
  local vx,vy,vz = -X, G.h-Y, -Z
  local facing = (nx*vx+ny*vy+nz*vz)/math.sqrt(vx*vx+vy*vy+vz*vz)
  if facing > 0.005 and cz > 0.3 and cx > -60 and cx < 1060 and cy < 1300 then
    local s = math.sqrt(2*math.pi*r*0.14*0.62*i^(-0.38)) * 1.25
    local X2,Y2,Z2 = G.dome(r+0.01,th)
    local ex,ey,ez = X2-X,Y2-Y,Z2-Z; local el=math.sqrt(ex*ex+ey*ey+ez*ez); ex,ey,ez=ex/el,ey/el,ez/el
    local tx,ty,tz = ny*ez-nz*ey, nz*ex-nx*ez, nx*ey-ny*ex
    local arc = {}
    for k=0,14 do
      local a = -1.3 + 2.6*k/14
      local u, v = 0.6*s*math.cos(a), 0.5*s*math.sin(a)
      local lift = 0.05*s
      local x,y = G.proj(X+ex*u+tx*v+nx*lift, Y+ey*u+ty*v+ny*lift, Z+ez*u+tz*v+nz*lift)
      arc[#arc+1] = {x,y}
    end
    PL[#PL+1] = {x=cx, y=cy, r=r, th=th, arc=arc}
  end
end
table.sort(PL, function(A,B) return A.r > B.r end)
print(#PL)

--@ chunk 9
LIPS = {
  pile{{"zinc white",3},{"lemon chrome",0.5}},
  pile{{"lead white",3},{"cadmium yellow",0.8},{"yellow ochre",0.4}},
  pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",1.0}},
}
DARKS = {
  pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6}},
  pile{{"burnt sienna",2},{"bone black",1},{"bone brown",1}},
  pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.6}},
}
function paint_plates(list)
  local lip = brush{kind="round", width=3, point=0.7}
  local dk = brush{kind="round", width=8, point=0.3}
  local n = 0
  for _,P in ipairs(list) do
    local minx,maxx,miny,maxy=1e9,-1e9,1e9,-1e9
    for _,q in ipairs(P.arc) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
    local w = maxx-minx
    if maxy > G.limbY(clamp(P.x,0,1000))+2 and w > 3 then
      n = n+1
      local rim = {}
      for _,q in ipairs(P.arc) do rim[#rim+1] = {q[1], math.max(q[2], G.limbY(clamp(q[1],0,1000))+1.5)} end
      local glare = math.exp(-((P.x-610)/260)^2) * math.exp(-(P.y-G.limbY(clamp(P.x,0,1000)))/120)
      local li = glare > 0.45 and 1 or (glare > 0.12 and 2 or 3)
      local di = P.y < 780 and 1 or (P.y < 950 and 2 or 3)
      local bw = clamp(w*0.06, 0.8, 12)
      if bw > 1.2 then
        local sh = {} for _,q in ipairs(rim) do sh[#sh+1] = {q[1], q[2]+bw*0.6} end
        dk:reload(DARKS[di], 0.7)
        dk:stroke(sh, {pressure={dk:pressure_for(bw), dk:pressure_for(bw)}, swell={0.3,1,1,0.3}})
      end
      local lw = clamp(w*0.02, 0.5, 3)
      lip:reload(LIPS[li], 0.65)
      lip:stroke(rim, {pressure={lip:pressure_for(lw)*0.7, lip:pressure_for(lw)*0.7}, swell={0.2,1,1,0.3}})
    end
  end
  return n
end
print(paint_plates(PL))

--@ chunk 10
print(wait(30*60))
LEGS = {
  {hip={412,640}, knee={305,515}, foot={262,752}, w={30,24,14}},
  {hip={352,690}, knee={196,548}, foot={140,868}, w={36,28,16}},
  {hip={372,762}, knee={226,700}, foot={238,1012}, w={42,32,19}},
  {hip={598,640}, knee={716,505}, foot={772,748}, w={30,24,14}},
  {hip={664,690}, knee={834,552}, foot={892,872}, w={36,28,16}},
  {hip={640,764}, knee={794,712}, foot={770,1018}, w={42,32,19}},
}
SP = {610, 690}
function shdir(x,y) local dx,dy = x-SP[1], y-SP[2]; local l=math.sqrt(dx*dx+dy*dy); return dx/l, dy/l end
local SH = pile{{"bone black",1.5},{"ultramarine blue",0.8},{"burnt sienna",0.6}}
local dome = below(function(x) return G.limbY(x)+1 end)
local m = poly({{340,800},{680,800},{740,1000},{790,1266},{220,1266},{270,1000}}, true):roughen(10,80,5)
for _,L in ipairs(LEGS) do
  local ux,uy = shdir(L.foot[1], L.foot[2])
  local pts, ws = {}, {}
  for t=0,700,50 do pts[#pts+1]={L.foot[1]+ux*t, L.foot[2]+uy*t}; ws[#ws+1]=lerp(L.w[3]*1.3, L.w[3]*3.4, t/700) end
  m = m + ribbon(pts, ws)
end
SHM = m * dome
work(SHM, {hand="body", pile=SH, coverage=3, fill=true, angle=function(x,y) local a,b=shdir(x,y) return math.atan(b,a) end, tool="filbert 12", edge="firm"})

--@ chunk 11
CAR = poly({{398,592},{450,576},{505,572},{560,575},{612,590},{660,622},{694,668},{708,716},{698,760},{664,792},{600,812},{505,818},{410,812},{346,792},{312,760},{304,716},{320,668},{352,622}}, true)
TOR = poly({{452,440},{470,428},{505,424},{540,428},{560,440},{566,470},{560,520},{556,580},{460,580},{452,520},{446,470}}, true)
HELM = ellipse(506, 382, 33, 38)
NECK = rect(490, 410, 32, 25)
local legm = nil
for _,L in ipairs(LEGS) do
  local m = ribbon({L.hip, {(L.hip[1]+L.knee[1])/2, (L.hip[2]+L.knee[2])/2 - 8}, L.knee}, {L.w[1], L.w[1]*0.9, L.w[2]})
          + ribbon({L.knee, {(L.knee[1]+L.foot[1])/2, (L.knee[2]+L.foot[2])/2}, L.foot}, {L.w[2], L.w[2]*0.8, L.w[3]})
          + ellipse(L.knee[1], L.knee[2], L.w[2]*0.8, L.w[2]*0.75)
          + poly({{L.foot[1]-L.w[3]*1.1, L.foot[2]+4},{L.foot[1]+L.w[3]*1.1, L.foot[2]+4},{L.foot[1], L.foot[2]-L.w[3]*1.6}})
  legm = legm and (legm + m) or m
end
LEGM = legm
BODY = CAR + TOR + HELM + NECK + LEGM
local DK1 = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
local DK2 = pile{{"bone brown",2},{"ultramarine blue",1}}
local DK3 = pile{{"burnt sienna",2},{"ultramarine blue",2},{"bone black",0.5}}
work(LEGM, {hand="body", pile=DK1, coverage=3, fill=true, tool="filbert 8", edge="found", clip=LEGM:grow(1)})
work(CAR, {hand="body", pile=DK3, coverage=3, fill=true, tool="filbert 12", angle=0.1, edge="found", clip=CAR:grow(1)})
work(TOR + NECK + HELM, {hand="body", pile=DK2, coverage=3, fill=true, tool="filbert 6", angle=math.pi/2, edge="found", clip=(TOR+NECK+HELM):grow(1)})

--@ chunk 12
local DK1 = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
local DK0 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
BELLY = poly({{350,780},{420,806},{505,812},{595,806},{664,780},{650,830},{600,862},{505,876},{410,862},{362,830}}, true)
work(BELLY, {hand="body", pile=DK0, coverage=3, fill=true, tool="filbert 10", angle=0, edge="found", clip=BELLY:grow(1)})
-- femur armour: thick tapered sleeves on the upper legs and coxae at the hips
local arm = nil
for _,L in ipairs(LEGS) do
  local mx,my = lerp(L.hip[1],L.knee[1],0.45), lerp(L.hip[2],L.knee[2],0.45)-6
  local m = ribbon({L.hip,{mx,my},{lerp(L.hip[1],L.knee[1],0.85), lerp(L.hip[2],L.knee[2],0.85)}}, {L.w[1]*1.5, L.w[1]*1.45, L.w[2]*1.05})
          + ellipse(L.hip[1], L.hip[2], L.w[1]*1.0, L.w[1]*0.85)
          + ribbon({L.knee,{lerp(L.knee[1],L.foot[1],0.35), lerp(L.knee[2],L.foot[2],0.35)}}, {L.w[2]*1.25, L.w[2]*1.1})
  arm = arm and (arm+m) or m
end
ARM = arm
work(ARM, {hand="body", pile=DK1, coverage=3, fill=true, tool="filbert 8", edge="found", clip=ARM:grow(1)})
-- carapace segment seams: darker bands across
SEAMS = {}
for k,yy in ipairs({612, 655, 705, 760}) do
  local pts = {}
  local half = ({140,175,190,185})[k]
  for i=0,12 do local t=i/12; local x=505-half+2*half*t; pts[#pts+1]={x, yy + 0.00055*(x-505)^2*(1+k*0.4) + 10*k*(1-((x-505)/half)^2)} end
  SEAMS[k] = pts
  work(ribbon(pts, 7+k*2)*CAR, {hand="body", pile=DK0, coverage=2.5, tool="filbert 4", angle=0, clip=CAR})
end
BODY = BODY + BELLY + ARM

--@ chunk 13
print(wait(48*60)); print(drying(505,700), drying(300,600), drying(505,480), drying(505,850))
local DK0 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.8}}
work(CAR, {hand="body", pile=DK0, coverage=3.5, fill=true, tool="filbert 10", angle=0.05, edge="found", clip=CAR})
-- antler masts: drawn with a round, trunk then tines
ANT = {
  {{470,445},{452,380},{420,300},{395,230},{380,170}},
  {{545,445},{566,370},{602,295},{640,230},{668,175}},
  {{415,600},{372,520},{318,430},{270,350},{236,300}},
  {{602,600},{656,512},{722,425},{780,350},{818,300}},
  {{455,585},{430,470},{400,360},{372,268},{330,120}},
  {{560,585},{596,470},{650,360},{712,262},{760,150}},
}
local TINES = {
  {{2,{396,312}},{3,{430,205}},{4,{350,150}}},
  {{2,{618,330}},{3,{612,190}},{4,{700,150}}},
  {{2,{300,500}},{3,{232,385}},{4,{262,250}}},
  {{2,{735,500}},{3,{812,400}},{4,{785,262}}},
  {{2,{455,360}},{3,{345,290}},{4,{392,175}}},
  {{2,{585,368}},{3,{700,320}},{4,{722,160}}},
}
local b = brush{kind="round", width=9, point=0.8}
for i,A in ipairs(ANT) do
  b:reload(DK0, 0.9)
  b:stroke(A, {pressure={b:pressure_for(i<=4 and 8 or 6), b:pressure_for(1.5)}})
  for _,t in ipairs(TINES[i]) do
    local s = A[t[1]+1]
    local m = {lerp(s[1], A[t[1]][1], 0.4), lerp(s[2], A[t[1]][2], 0.4)}
    b:reload(DK0, 0.7)
    b:stroke({m, {lerp(m[1],t[2][1],0.5)+3, lerp(m[2],t[2][2],0.5)}, t[2]}, {pressure={b:pressure_for(4.5), b:pressure_for(0.8)}})
  end
end

--@ chunk 14
local DK0 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.8}}
local b = brush{kind="round", width=16, point=0.6}
print(b:mark_width(1), b:mark_width(0.5), b:mark_width(0.2))
for i,A in ipairs(ANT) do
  b:reload(DK0, 1)
  local w0 = (i<=4) and 9 or 7
  b:stroke(A, {pressure={b:pressure_for(w0), b:pressure_for(2.5)}, swell={1.1,1,0.9,0.8,0.7}})
end

--@ chunk 15
local DK0 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.8}}
local m = nil
for i,A in ipairs(ANT) do
  local w0 = (i<=4) and 11 or 9
  local ws = {} for k=1,#A do ws[k] = lerp(w0, 3, (k-1)/(#A-1)) end
  local r = ribbon(A, ws)
  m = m and (m+r) or r
end
ANTM = m
work(ANTM, {hand="detail", pile=DK0, coverage=4, fill=true, angle=function(x,y) return -1.4 end, clip=ANTM})

--@ chunk 16
print(wait(72*60)); print(drying(505,700), drying(300,600), drying(505,480), drying(420,400))
local ALL = BODY + ANTM
local rim = ALL:rim(3.2, 0.5)
local near = mask(function(x,y) local d=math.sqrt((x-SUN.x)^2+(y-SUN.y)^2)/SUN.r; return (d<1.02 and y < G.limbY(clamp(x,0,1000))+30) and 1 or 0 end):soften(10)
local hot = pile{{"zinc white",3},{"lemon chrome",0.6},{"cadmium yellow",0.3}}
local warm = pile{{"cadmium yellow",1.5},{"Mars orange",1},{"lead white",0.6}}
work(rim*near, {hand="detail", pile=hot, coverage=3, fill=true, clip=rim})
work(rim - near, {hand="detail", pile=warm, coverage=1.6, clip=rim, load=0.5})

--@ chunk 17
print(wait(36*60)); print(drying(330,560), drying(250,700))
local DK0 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.8}}
local DK1 = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
local L = (LEGM + ARM):grow(1.5)
work(L, {hand="body", pile=DK1, coverage=3.5, fill=true, tool="filbert 6", edge="found", clip=L})
local A = ANTM:grow(1.2) - CAR - TOR
work(A, {hand="detail", pile=DK0, coverage=4, fill=true, angle=-1.4, clip=A})

--@ chunk 18
print(wait(4*24*60)); print(drying(330,560), drying(250,700), drying(420,400))
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local L = (LEGM + ARM):grow(2)
work(L, {hand="body", pile=DK0, coverage=4, fill=true, tool="filbert 6", edge="found", clip=L})
local A = ANTM:grow(1.5) - CAR - TOR
work(A, {hand="detail", pile=DK0, coverage=5, fill=true, angle=-1.4, clip=A, load=1})
local B = BELLY:grow(3) * below(function(x) return 790 end)
work(B, {hand="body", pile=DK0, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=B})

--@ chunk 19
print(wait(2*24*60)); print(drying(330,560), drying(250,700), drying(505,650))
local hot = pile{{"zinc white",3},{"lemon chrome",0.6},{"cadmium yellow",0.3}}
local warm = pile{{"cadmium yellow",1.2},{"Mars orange",1},{"lead white",0.8}}
local dull = pile{{"Mars orange",1},{"burnt sienna",1},{"yellow ochre",0.6}}
local lip = brush{kind="round", width=4, point=0.8}
local function insun(x,y) return math.sqrt((x-SUN.x)^2+(y-SUN.y)^2) < SUN.r*0.98 and y < G.limbY(clamp(x,0,1000)) end
local function edge(a, b, wa, wb, lw)
  -- the edge of segment a->b on the side facing the sun
  local mx,my = (a[1]+b[1])/2, (a[2]+b[2])/2
  local dx,dy = b[1]-a[1], b[2]-a[2]; local l=math.sqrt(dx*dx+dy*dy); dx,dy=dx/l,dy/l
  local nx,ny = -dy, dx
  if nx*(SUN.x-mx)+ny*(SUN.y-150-my) < 0 then nx,ny = -nx,-ny end
  local pts = {}
  for i=0,8 do local t=0.08+0.84*i/8; local w=lerp(wa,wb,t)/2-1.2
    pts[#pts+1] = {lerp(a[1],b[1],t)+nx*w, lerp(a[2],b[2],t)+ny*w} end
  local s = pts[5]
  lip:reload(insun(s[1],s[2]) and hot or warm, 0.7)
  lip:stroke(pts, {pressure={lip:pressure_for(lw), lip:pressure_for(lw*0.6)}, swell={0.3,1,1,0.8,0.2}})
end
for _,L in ipairs(LEGS) do
  edge(L.hip, L.knee, L.w[1]*1.4, L.w[2]*1.05, 2.4)
  edge(L.knee, L.foot, L.w[2], L.w[3], 1.8)
  -- armour rings across the femur
  for _,t in ipairs({0.3, 0.55, 0.78}) do
    local x,y = lerp(L.hip[1],L.knee[1],t), lerp(L.hip[2],L.knee[2],t)
    local dx,dy = L.knee[1]-L.hip[1], L.knee[2]-L.hip[2]; local l=math.sqrt(dx*dx+dy*dy); dx,dy=dx/l,dy/l
    local w = lerp(L.w[1]*1.4, L.w[2]*1.05, t)/2 - 2
    lip:reload(dull, 0.5)
    lip:stroke({{x-dy*w, y+dx*w},{x+dx*2, y+dy*2},{x+dy*w, y-dx*w}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(0.6)}})
  end
end
-- carapace segment lips, lit dully toward the far side
for k,pts in ipairs(SEAMS) do
  local sh = {} for _,q in ipairs(pts) do sh[#sh+1] = {q[1], q[2]-5-k} end
  lip:reload(k<=2 and warm or dull, 0.6)
  lip:stroke(sh, {pressure={lip:pressure_for(1.6), lip:pressure_for(1.6)}, swell={0.1,0.8,1,1,0.8,0.1}, clip=CAR:shrink(4)})
end

--@ chunk 20
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local T = (TOR:shrink(2.5) + HELM:shrink(2.5) + NECK) - CAR
work(T, {hand="body", pile=DK0, coverage=4, fill=true, tool="filbert 5", angle=math.pi/2, clip=T})
-- the old pauldrons: shoulder plates of the first frame
local pl = ellipse(458, 448, 20, 15) + ellipse(553, 446, 20, 15)
work(pl, {hand="body", pile=DK0, coverage=4, fill=true, tool="filbert 5", clip=pl})
print(wait(3*24*60))

--@ chunk 21
RAG = poly({{446,436},{470,428},{492,432},{520,432},{544,428},{566,438},{572,456},{566,478},{560,500},{554,512},{545,505},{538,522},{528,512},{516,534},{506,516},{496,528},{486,512},{474,540},{468,560},{462,592},{455,575},{452,548},{450,520},{444,496},{440,470}}, false):roughen(1.5, 12, 4)
local C1 = pile{{"Mars red",2},{"rose madder",1},{"bone brown",0.6}}
local C2 = pile{{"vermilion",2},{"cadmium red",1},{"Mars red",0.5}}
work(RAG, {hand="body", pile=C1, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2+0.1, clip=RAG})
-- light through the cloth along its top and its torn edges
local glow = RAG:rim(4, 0.6) * above(function(x) return 470 end)
work(glow, {hand="detail", pile=C2, coverage=2, clip=RAG, load=0.6})
-- folds
local b = brush{kind="round", width=4, point=0.6}
local D = pile{{"bone brown",2},{"rose madder",1},{"ultramarine blue",0.4}}
for _,f in ipairs({{{478,440},{474,480},{470,520}},{{510,440},{508,480},{506,512}},{{538,440},{540,475},{538,505}}}) do
  b:reload(D, 0.6); b:stroke(f, {pressure={b:pressure_for(2.5), b:pressure_for(1)}, clip=RAG})
end

--@ chunk 22
print(wait(2*24*60)); print(drying(500,480))
local C0 = pile{{"rose madder",2},{"Mars red",1.5},{"bone black",0.35},{"vermilion",0.3}}
local body = RAG * below(function(x) return 452 end) * mask(function(x,y) return (x < 556) and 1 or 0 end):soften(6)
work(body, {hand="body", pile=C0, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2+0.08, clip=RAG})
-- the cold leak of the old visor: blue light spilling round the right of the helmet
local BL = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt blue",0.3}}
local BD = pile{{"cobalt blue",1.5},{"cerulean blue",1},{"ultramarine blue",0.5}}
local b = brush{kind="round", width=4, point=0.8}
b:reload(BD, 0.7); b:stroke({{528,360},{536,382},{532,404},{520,416}}, {pressure={b:pressure_for(1), b:pressure_for(3.2)}, swell={0.3,1,1,0.6}})
b:reload(BL, 0.7); b:stroke({{531,372},{536,388},{530,404}}, {pressure={b:pressure_for(0.8), b:pressure_for(1.6)}, swell={0.4,1,0.6}})
b:reload(BD, 0.5); b:stroke({{524,420},{528,436},{526,452}}, {pressure={b:pressure_for(1.8), b:pressure_for(0.4)}})
b:reload(BL, 0.4); b:stroke({{540,436},{556,434},{568,440}}, {pressure={b:pressure_for(1.2), b:pressure_for(0.5)}})
b:reload(BD, 0.4); b:stroke({{548,420},{556,404},{566,388}}, {pressure={b:pressure_for(1.2), b:pressure_for(0.4)}})

--@ chunk 23
local BL = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt blue",0.3}}
local BD = pile{{"cobalt blue",1.5},{"cerulean blue",1},{"ultramarine blue",0.5}}
local cres = (HELM:shrink(2.6) - ellipse(495, 379, 31, 38)) * below(function(x) return 352 end)
work(cres, {hand="detail", pile=BD, coverage=3, fill=true, clip=cres})
local core = (HELM:shrink(2.6) - ellipse(492, 378, 34, 39)) * below(function(x) return 366 end) * above(function(x) return 410 end)
work(core, {hand="detail", pile=BL, coverage=2.5, fill=true, clip=core})
-- a cold seep under the helmet rim onto the collar
local seep = ellipse(522, 420, 9, 6):soften(2)
work(seep, {hand="detail", pile=BD, coverage=2, clip=seep:grow(2)})
-- break the regular hem: ragged threads and a torn strip
local C1 = pile{{"Mars red",2},{"rose madder",1},{"bone brown",0.6}}
local b = brush{kind="round", width=3, point=0.9}
for _,t in ipairs({{{498,522},{500,540},{497,556}},{{520,526},{523,548}},{{536,516},{540,530},{538,546},{541,560}},{{508,530},{506,544}},{{548,508},{553,522}}}) do
  b:reload(C1, 0.6); b:stroke(t, {pressure={b:pressure_for(2.6), 0}})
end

--@ chunk 24
print(wait(24*60)); print(drying(530,390), drying(505,840))
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local cover = (HELM:shrink(2.6) * ellipse(500, 381, 32, 37)) + ellipse(522, 421, 12, 9)
work(cover, {hand="detail", pile=DK0, coverage=4, fill=true, clip=cover})
-- the caged graft slung beneath the carapace
CAGE = ellipse(505, 846, 50, 22)
local V1 = pile{{"ultramarine blue",1.5},{"magenta",1},{"cobalt violet",1},{"bone black",0.3}}
local V2 = pile{{"cobalt violet",1.5},{"magenta",0.6},{"zinc white",1.2},{"cerulean blue",0.3}}
work(CAGE, {hand="body", pile=V1, coverage=3, fill=true, tool="filbert 5", clip=CAGE})
local inner = ellipse(498, 850, 28, 11):roughen(4, 14, 9)
work(inner, {hand="scumble", pile=V2, coverage=1.4, load=0.5, clip=CAGE})

--@ chunk 25
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
-- cage bars and hoops
local bars = nil
for i=-4,4 do
  local x = 505 + i*11
  local hh = 22*math.sqrt(math.max(0, 1-((x-505)/50)^2))
  local r = ribbon({{x, 846-hh-3},{x+0.5, 846},{x, 846+hh+2}}, {2.4, 2.8, 2.4})
  bars = bars and (bars + r) or r
end
local hoops = ribbon({{455,846},{480,838},{505,836},{530,838},{555,846}}, 3) + ribbon({{456,850},{480,862},{505,866},{530,862},{554,850}}, 3)
work(bars + hoops, {hand="detail", pile=DK0, coverage=4, fill=true, clip=(bars+hoops):grow(0.5)})
-- tines: heavier branching on the antler masts
local T = {
  {{410,290},{385,250},{372,215}}, {{432,330},{462,290},{476,250}}, {{392,215},{410,180},{418,150}},
  {{610,300},{640,262},{650,222}}, {{590,330},{562,292},{556,260}}, {{652,215},{632,180},{630,150}},
  {{300,420},{262,400},{236,370}}, {{262,345},{290,310},{298,280}},
  {{728,418},{770,398},{798,366}}, {{785,345},{758,312},{752,282}},
  {{392,330},{360,300},{344,262}}, {{372,262},{396,226},{400,196}},
  {{660,342},{698,318},{720,284}}, {{715,255},{690,222},{688,190}},
}
local tm = nil
for _,t in ipairs(T) do local r = ribbon(t, {5.5, 4, 2}); tm = tm and (tm+r) or r end
work(tm, {hand="detail", pile=DK0, coverage=5, fill=true, angle=-1.3, clip=tm:grow(0.5)})
-- the plates go on under the pooled shadow, dimly
local lip = brush{kind="round", width=3, point=0.7}
local dim = pile{{"burnt sienna",1},{"yellow ochre",0.8},{"bone brown",0.6},{"lead white",0.15}}
local n=0
for _,P in ipairs(PL) do
  if SHM:at(P.x, P.y) > 0.5 and P.y > 880 and CAGE:at(P.x,P.y) < 0.1 then
    local minx,maxx = 1e9,-1e9
    for _,q in ipairs(P.arc) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) end
    local lw = clamp((maxx-minx)*0.018, 0.5, 2.5)
    lip:reload(dim, 0.55)
    lip:stroke(P.arc, {pressure={lip:pressure_for(lw)*0.7, lip:pressure_for(lw)*0.7}, swell={0.2,1,1,0.3}, clip=SHM})
    n=n+1
  end
end
print(n)

--@ chunk 26
local lip = brush{kind="round", width=4, point=0.8}
local dull = pile{{"Mars orange",1},{"burnt sienna",1},{"yellow ochre",0.7},{"lead white",0.2}}
local bounce = pile{{"Mars orange",1.5},{"cadmium yellow",0.5},{"burnt sienna",0.6}}
-- scale plates on the carapace's rear, the hull's own pattern grown over it
local rows = {{y=728, n=5, half=150, s=30}, {y=770, n=6, half=165, s=28}, {y=806, n=5, half=130, s=26}}
for ri,R in ipairs(rows) do
  for i=0,R.n-1 do
    local x = 505 - R.half + (2*R.half)*(i+0.5)/R.n + rand(-6,6)
    local y = R.y + 0.0006*(x-505)^2 + rand(-3,3)
    local s = R.s*(1 - math.abs(x-505)/600)
    local arc = {}
    for k=0,10 do local a = math.pi*(0.1+0.8*k/10); arc[#arc+1] = {x + s*math.cos(a), y + 0.45*s*math.sin(a)} end
    if CAR:at(x,y) + BELLY:at(x,y) > 0.5 and CAGE:at(x,y+8) < 0.1 then
      lip:reload(dull, 0.5)
      lip:stroke(arc, {pressure={lip:pressure_for(1.4), lip:pressure_for(1.4)}, swell={0.2,1,1,1,0.2}, clip=(CAR+BELLY):shrink(3)})
    end
  end
end
-- warm light thrown up from the bright hull onto the undersides of the femurs
for _,L in ipairs(LEGS) do
  local a,b = L.hip, L.knee
  local dx,dy = b[1]-a[1], b[2]-a[2]; local l=math.sqrt(dx*dx+dy*dy); dx,dy=dx/l,dy/l
  local nx,ny = -dy, dx; if ny < 0 then nx,ny = -nx,-ny end
  local pts = {}
  for i=0,6 do local t=0.35+0.55*i/6; local w=lerp(L.w[1]*1.4, L.w[2]*1.05, t)/2-1.5
    pts[#pts+1] = {lerp(a[1],b[1],t)+nx*w, lerp(a[2],b[2],t)+ny*w} end
  lip:reload(bounce, 0.5)
  lip:stroke(pts, {pressure={lip:pressure_for(1.6), lip:pressure_for(0.6)}, swell={0.2,1,1,0.5}})
end
-- the belly's lower lip catches the hull's glow
lip:reload(bounce, 0.5)
lip:stroke({{380,846},{420,864},{460,872},{505,874}}, {pressure={lip:pressure_for(0.5), lip:pressure_for(1.6)}, clip=BELLY})
lip:reload(bounce, 0.5)
lip:stroke({{556,872},{600,860},{640,840}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(0.5)}, clip=BELLY})

--@ chunk 27
print(wait(24*60))
-- the Adversary behind the bars: a few pale eyes
local eye = brush{kind="round", width=2.5, point=0.9}
local EY = pile{{"zinc white",3},{"cerulean blue",0.4},{"cobalt violet",0.3}}
for _,p in ipairs({{482,842},{497,852},{514,845},{528,853},{506,838}}) do
  eye:reload(EY, 0.6); eye:touch(p[1], p[2], {pressure=0.35})
end
-- its light seeping onto the belly's rim beneath
local VG = pile{{"cobalt violet",1},{"magenta",0.4},{"zinc white",0.6}, medium=0.4}
local vs = (ellipse(505, 872, 46, 8) * BELLY):soften(3)
work(vs, {hand="detail", pile=VG, coverage=1.2, load=0.4, clip=BELLY})
-- glare eating into the silhouette round the helmet: the halo
local halo = (HELM:grow(7) - HELM:grow(1)) + ((TOR+RAG):grow(5) - (TOR+RAG):grow(1)) * above(function(x) return 470 end)
local hot = pile{{"zinc white",3},{"lemon chrome",0.3}}
stipple(halo, {pile=hot, width=1.8, pressure={0.3,0.6}, coverage=1.2, feather=0.5})
-- feet: a hot glint where each foot bites the plates, and its own contact dark
local SHD = pile{{"bone black",2},{"ultramarine blue",1}}
local g = brush{kind="round", width=5, point=0.6}
local warm = pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",1}}
for _,L in ipairs(LEGS) do
  local f = L.foot
  g:reload(SHD, 0.7); g:stroke({{f[1]-L.w[3]*1.3, f[2]+4},{f[1]+L.w[3]*1.3, f[2]+5}}, {pressure={g:pressure_for(3), g:pressure_for(2)}})
  g:reload(warm, 0.5); g:stroke({{f[1]-L.w[3]*0.9, f[2]-2},{f[1]-L.w[3]*0.2, f[2]-L.w[3]*1.0}}, {pressure={g:pressure_for(1.2), g:pressure_for(0.3)}})
end
-- a few stars in the dark corner
local st = brush{kind="round", width=2, point=1}
for _,p in ipairs({{48,60},{120,32},{86,140},{22,210},{930,40},{965,95}}) do
  st:reload(pile{{"zinc white",1}}, 0.4); st:touch(p[1], p[2], {pressure=0.25})
end

--@ chunk 28
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local up = above(function(x) return G.limbY(x)+4 end)
local keep = up - ANTM:grow(32) - BODY:grow(4)
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local M12 = pile{{"burnt sienna",2},{"bone brown",1},{"Mars red",0.4},{"ultramarine blue",0.3}}
local M23 = pile{{"Mars orange",1.5},{"burnt sienna",1.2},{"red earth",0.3}}
local M34 = pile{{"Mars orange",1.2},{"cadmium yellow",1},{"Indian yellow",0.3}}
work(((E(1.95)-E(1.6))*keep):roughen(14,70,11), {hand="scumble", pile=M12, coverage=1.6, angle=rad, load=0.35, clip=keep})
work(((E(1.5)-E(1.25))*keep):roughen(12,60,12), {hand="scumble", pile=M23, coverage=1.6, angle=rad, load=0.35, clip=keep})
work(((E(1.2)-E(1.06))*keep):roughen(8,50,13), {hand="scumble", pile=M34, coverage=1.4, angle=rad, load=0.35, clip=keep})

--@ chunk 29
print(wait(24*60))
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local tips = nil
for _,p in ipairs({{417,157},{473,259},{290,309},{237,372},{631,157},{150+1150/2.4, 80+185/2.4}}) do
  local e = ellipse(p[1], p[2], 3.5, 3.5); tips = tips and (tips+e) or e
end
work(tips, {hand="detail", pile=DK0, coverage=4, fill=true, clip=tips})
local neck = ellipse(511, 420, 22, 7)
work(neck, {hand="detail", pile=DK0, coverage=4, fill=true, clip=neck})
local C2 = pile{{"vermilion",1.5},{"Mars red",1},{"rose madder",0.5}}
local top = RAG * above(function(x) return 446 end) - neck
work(top, {hand="detail", pile=C2, coverage=3.5, fill=true, clip=top})
-- the halo line closed round the helmet
local b = brush{kind="round", width=3, point=0.8}
local pts = {}
for i=0,40 do local a = math.pi*(0.95 + 1.1*i/40); pts[#pts+1] = {506 + 34.6*math.cos(a), 382 + 39.6*math.sin(a)} end
b:reload(pile{{"zinc white",3},{"lemon chrome",0.4}}, 0.7)
b:stroke(pts, {pressure={b:pressure_for(2), b:pressure_for(2)}, swell={0.3,1,1,1,0.3}})

--@ chunk 30
local pl = ellipse(458, 448, 20, 15) + ellipse(553, 446, 20, 15)
local S = TOR + RAG + pl + HELM + NECK
local ring = (S:grow(7) - S:grow(1.2)) * above(function(x) return 470 end) - ANTM:grow(1)
local pc = pile{{"zinc white",4},{"lemon chrome",0.3},{"cadmium yellow",0.1}}
work(ring, {hand="detail", pile=pc, coverage=3.5, fill=true, clip=ring})
local seam = RAG * below(function(x) return 438 end) * above(function(x) return 456 end)
blend(seam, {angle=math.pi/2, tool={kind="badger", width=8}})

--@ chunk 31
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local sh = (ellipse(450, 438, 16, 11) + ellipse(562, 436, 14, 11) + ellipse(526, 421, 7, 5)) - RAG
work(sh, {hand="detail", pile=DK0, coverage=4, fill=true, clip=sh})
local C2 = pile{{"vermilion",1.2},{"Mars red",1},{"rose madder",0.8}}
local b = brush{kind="filbert", width=5}
for _,x in ipairs({456, 470, 489, 503, 521, 534, 550}) do
  b:reload(C2, 0.35)
  b:stroke({{x, 442},{x+rand(-2,2), 458},{x+rand(-3,3), 470+rand(0,12)}}, {pressure={0.6, 0.05}, clip=RAG})
end

--@ chunk 32
local DK0 = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local b = brush{kind="round", width=5, point=0.9}
for _,s in ipairs({{{232,382},{241,370},{246,362}}, {{466,270},{471,261},{475,252}}, {{680,226},{687,216},{690,206}}, {{466,238},{470,262}}}) do
  b:reload(DK0, 0.8); b:stroke(s, {pressure={b:pressure_for(3), b:pressure_for(0.6)}})
end

