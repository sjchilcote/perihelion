-- easel session "title": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={16,14}, seed=1717, ground={{pile={{"Mars brown",2},{"bone brown",1},{"lead white",1},{"raw sienna",0.5}}, um=120, apply="knife", texture=0.3}}}; print(W,H)

--@ chunk 2
cx,cy,R=1080,700,520
tang=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local disc=ellipse(cx,cy,R,R)
local function ring(a,b,s) return (ellipse(cx,cy,b,b)-ellipse(cx,cy,a,a)):roughen(16,120,s) end
gl={
 pile{{"lead white",4},{"lemon chrome",1},{"cadmium yellow",0.5}},
 pile{{"lead white",2},{"cadmium yellow",2},{"chrome yellow",1}},
 pile{{"cadmium yellow",1},{"Mars orange",1.2},{"lead white",0.3}},
 pile{{"vermilion",1},{"Mars orange",1},{"red earth",0.5}},
 pile{{"Mars red",1},{"red earth",1},{"bone brown",1},{"rose madder",0.5}},
 pile{{"bone brown",2},{"Mars brown",1},{"ultramarine blue",1},{"bone black",0.7}},
 pile{{"bone black",2},{"ultramarine blue",2},{"burnt sienna",1.2}},
}
local edges={R-10,555,605,680,775,880,985,2000}
for i=1,7 do
  work(ring(edges[i],edges[i+1],i)-disc,{hand="broad",pile=gl[i],coverage=2.8,fill=true,angle=tang})
end
blend(-disc,{angle=tang})

--@ chunk 3
local disc=ellipse(cx,cy,R,R)
sun_core=pile{{"lead white",10},{"lemon chrome",1}}
sun_limb=pile{{"lead white",4},{"lemon chrome",1},{"cadmium yellow",1}}
work(disc:shrink(50),{hand="broad",pile=sun_core,coverage=4,fill=true,angle=tang,clip=disc})
work(disc-disc:shrink(60),{hand="body",pile=sun_limb,coverage=4,fill=true,clip=disc,angle=tang})
blend(disc,{angle=tang})
work(disc:shrink(110),{hand="broad",pile=sun_core,coverage=2.5,fill=true,angle=tang,clip=disc})

--@ chunk 4
print(wait(3*24*60)); print(drying(900,400), drying(200,200), drying(560,400))

--@ chunk 5
local disc=ellipse(cx,cy,R,R)
local function ring(a,b,s) return (ellipse(cx,cy,b,b)-ellipse(cx,cy,a,a)):roughen(16,120,s) end
gz_gold=pile{{"Indian yellow",2},{"cadmium yellow",1},{"Mars orange",0.5},medium=0.85}
gz_red=pile{{"Indian yellow",1},{"rose madder",1},{"Mars orange",0.6},medium=0.85}
work(ring(R-5,640,21)-disc,{hand="glaze",pile=gz_gold,coverage=0.9,angle=tang,clip=-disc})
work(ring(620,800,22)-disc,{hand="glaze",pile=gz_red,coverage=0.8,angle=tang,clip=-disc})

--@ chunk 6
local disc=ellipse(cx,cy,R,R)
sun_white=pile{{"lead white",14},{"lemon chrome",1}}
work(disc:shrink(45):roughen(10,80,6),{hand="body",tool="filbert 14",pile=sun_white,coverage=5,load=1,fill=true,angle=tang,clip=disc})
blend(disc:shrink(40),{angle=tang})

--@ chunk 7
local disc=ellipse(cx,cy,R,R)
local mid=pile{{"lead white",8},{"lemon chrome",1},{"cadmium yellow",0.6}}
work(disc:shrink(22)-disc:shrink(78),{hand="body",pile=mid,coverage=3,fill=true,angle=tang,clip=disc})
blend(disc:shrink(12),{angle=tang})
blend(disc:shrink(12)-disc:shrink(90),{angle=tang})

--@ chunk 8
print(wait(4*24*60))
print(drying(800,450),drying(950,500),drying(200,200))
local far=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2); return smoothstep(860,1010,d) end)
gz_dark=pile{{"ultramarine blue",2},{"bone black",1},{"burnt sienna",1},medium=0.7}
work(far,{hand="glaze",pile=gz_dark,coverage=1.5,angle=tang,load_at=function(x,y) return 0.4+0.6*far:at(x,y) end})

--@ chunk 9
print(wait(3*24*60))
print(drying(100,100),drying(400,300))
local far=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2); return smoothstep(880,1060,d) end)
gz_dark2=pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5},{"rose madder",0.3},medium=0.6}
work(far,{hand="glaze",pile=gz_dark2,coverage=1.6,angle=tang,load_at=function(x,y) return 0.3+0.7*far:at(x,y) end})

--@ chunk 10
local far=(-ellipse(cx,cy,940,940)):roughen(20,140,31)
deep=pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1},{"rose madder",0.3}}
work(far,{hand="broad",pile=deep,coverage=3,fill=true,angle=tang,edge="lost"})
blend(-ellipse(cx,cy,900,900),{angle=tang})

--@ chunk 11
-- station geometry (globals)
SC={720,372}
SU={math.cos(-0.97),math.sin(-0.97)}  -- ring major axis dir (up-right)
SV={math.cos(0.6),math.sin(0.6)}      -- spine axis dir (down-right, away/toward sun)
RA,RB=180,74
RW=21
RT=0.07
function spt(s,t) return {SC[1]+s*SU[1]+t*SV[1], SC[2]+s*SU[2]+t*SV[2]} end
function ringpt(ang,scale,off)  -- point on ring ellipse at parameter ang, radial scale, axial offset
  return spt(RA*scale*math.cos(ang), RB*scale*math.sin(ang)+off)
end
function ellpoly(scale,off,n)
  local pts={}
  for i=0,(n or 180)-1 do local a=2*math.pi*i/(n or 180); local p=ringpt(a,scale,off); pts[#pts+1]=p end
  return poly(pts)
end
function ring_mask()
  local m
  for k=0,6 do
    local off=-RW/2+RW*k/6
    local an=ellpoly(1,off)-ellpoly(1-RT,off)
    m = m and (m+an) or an
  end
  return m
end
-- spine: list of segments {t0,t1,w0,w1}
function spine_poly(t0,t1,w0,w1)
  local a=spt(0,t0); local b=spt(0,t1)
  local nx,ny=-SV[2],SV[1]
  return poly({{a[1]+nx*w0/2,a[2]+ny*w0/2},{b[1]+nx*w1/2,b[2]+ny*w1/2},{b[1]-nx*w1/2,b[2]-ny*w1/2},{a[1]-nx*w0/2,a[2]-ny*w0/2}})
end
function blob(t,len,wid,s)   -- an ellipse-ish tank along the spine at t
  local pts={}
  local nx,ny=-SV[2],SV[1]
  local c=spt(s or 0,t)
  for i=0,47 do local a=2*math.pi*i/48
    local x,y=len/2*math.cos(a), wid/2*math.sin(a)
    pts[#pts+1]={c[1]+x*SV[1]+y*nx, c[2]+x*SV[2]+y*ny} end
  return poly(pts,true)
end
function bell(t0,t1,w0,w1,s,pw)
  local nx,ny=-SV[2],SV[1]
  local L,R={},{}
  for i=0,14 do local f=i/14; local t=lerp(t0,t1,f); local w=lerp(w0,w1,f^(pw or 0.45))
    local c=spt(s or 0,t); L[#L+1]={c[1]+nx*w/2,c[2]+ny*w/2}; table.insert(R,1,{c[1]-nx*w/2,c[2]-ny*w/2}) end
  for _,p in ipairs(R) do L[#L+1]=p end
  return poly(L)
end
function station_parts()
  local P={}
  P.ring=ring_mask()
  P.maw=bell(-250,-214,66,30)
  P.lip=spine_poly(-252,-246,72,70)
  P.trunk1=spine_poly(-216,-15,32,26)
  P.collar1=spine_poly(-206,-197,42,42)
  P.t1=blob(-166,50,52,3); P.t1b=blob(-158,30,30,-24)
  P.t2=blob(-120,34,42,-4); P.t2b=blob(-116,26,26,20)
  P.t3=blob(-84,22,34,0)
  P.collar2=spine_poly(-52,-44,36,36)
  P.hub=blob(0,38,84)
  P.hub2=blob(0,58,40)
  P.trunk2=spine_poly(15,238,24,14)
  P.m1=blob(72,62,36); P.m1b=blob(100,20,22,-14)
  P.vault=spine_poly(138,190,30,26); P.v2=spine_poly(198,208,22,22); P.cap=blob(240,14,24)
  local sp
  for i,a in ipairs({0.5,1.75,3.0,4.25,5.4}) do
    local p=ringpt(a,1-RT,0)
    local r=ribbon({SC,p},{6,4})
    sp = sp and (sp+r) or r
  end
  P.spokes=sp
  local all
  for _,m in pairs(P) do all = all and (all+m) or m end
  P.all=all
  return P
end
SP=station_parts()
sdark=pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",1}}
work(SP.all,{hand="body",tool="filbert 6",pile=sdark,coverage=4,fill=true,clip=true,angle=function(x,y) return 0.6 end})

--@ chunk 12
print(wait(3*24*60)); local c=spt(0,-166); print(drying(c[1],c[2])); local r=ringpt(3.9,0.97,0); print(drying(r[1],r[2]))

--@ chunk 13
print(wait(4*24*60)); local c=spt(0,-166); print(drying(c[1],c[2])); local r=ringpt(3.9,0.97,0); print(drying(r[1],r[2]))

--@ chunk 14
print(wait(10*24*60)); local c=spt(0,-166); print(drying(c[1],c[2])); local r=ringpt(3.9,0.97,0); print(drying(r[1],r[2]))

--@ chunk 15
function sundir(x,y) local dx,dy=1080-x,700-y; local l=math.sqrt(dx*dx+dy*dy); return dx/l,dy/l end
function rimmask(m,w,bb,both)
  return mask(function(x,y)
    if x<bb[1] or x>bb[3] or y<bb[2] or y>bb[4] then return 0 end
    if m:at(x,y)<0.5 then return 0 end
    local dx,dy=sundir(x,y)
    if m:at(x+w*dx,y+w*dy)<0.5 then return 1 end
    if both and m:at(x-w*0.6*dx,y-w*0.6*dy)<0.5 then return 0.6 end
    return 0
  end)
end
-- golden-angle scale plates over a blob on the spine: a bronze touch, then a dark shadow touch on its far side
function plates_on_blob(t,len,wid,s,n,piles,size,seed,clipm)
  local nx,ny=-SV[2],SV[1]
  local c=spt(s or 0,t)
  local b=brush{kind="round",width=size,stiffness=0.4}
  local d=brush{kind="round",width=size*0.75,stiffness=0.4}
  local pts={}
  for i=1,n do
    local r=math.sqrt((i-0.5)/n)*0.92
    local a=i*2.399963+(seed or 0)
    local lx,ly=len/2*r*math.cos(a), wid/2*r*math.sin(a)
    local ox,oy=lx*SV[1]+ly*nx, lx*SV[2]+ly*ny
    local x,y=c[1]+ox,c[2]+oy
    local sx,sy=sundir(x,y)
    local face=(ox*sx+oy*sy)/(math.max(len,wid)/2)
    pts[#pts+1]={x,y,face,a,sx,sy,r}
  end
  for _,q in ipairs(pts) do
    local p=piles[q[3]>0.4 and 3 or (q[3]>-0.15 and 2 or 1)]
    b:reload(p,0.55)
    local k=1-0.45*q[7]^2
    b:touch(q[1],q[2],{pressure=rand(0.8,1)*k,drag={q[5]*1.2,q[6]*1.2},angle=q[4],clip=clipm})
  end
  for _,q in ipairs(pts) do
    d:reload(piles[0] or piles.dark,0.5)
    local k=1-0.45*q[7]^2
    d:touch(q[1]-q[5]*size*0.45*k,q[2]-q[6]*size*0.45*k,{pressure=rand(0.7,0.9)*k,angle=q[4],clip=clipm})
  end
end
pl_dk=pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.5}}
pl_d=pile{{"bone brown",2},{"burnt sienna",1}}
pl_m=pile{{"burnt sienna",2},{"bone brown",1},{"yellow ochre",0.6}}
pl_l=pile{{"burnt sienna",1},{"yellow ochre",1},{"red earth",0.5}}
pl_sd=pile{{"bone black",1},{"bone brown",1},{"burnt sienna",0.5}}
local PL={pl_d,pl_m,pl_l,dark=pl_dk}
local PD={pl_sd,pl_d,pl_m,dark=pl_dk}
plates_on_blob(-166,50,52,3,40,PL,6,0,SP.t1)
plates_on_blob(-158,30,30,-24,14,PL,5,1,SP.t1b)
plates_on_blob(-120,34,42,-4,22,PL,5,2,SP.t2)
plates_on_blob(-116,26,26,20,11,PL,4.5,3,SP.t2b)
plates_on_blob(-84,22,34,0,12,PL,4.5,4,SP.t3)
plates_on_blob(0,38,84,0,34,PD,5.5,5,SP.hub)
plates_on_blob(72,62,36,0,26,PD,5,6,SP.m1)

--@ chunk 16
function sundir(x,y) local dx,dy=1080-x,700-y; local l=math.sqrt(dx*dx+dy*dy); return dx/l,dy/l end
function rimmask(m,w,bb,both)
  return mask(function(x,y)
    if x<bb[1] or x>bb[3] or y<bb[2] or y>bb[4] then return 0 end
    if m:at(x,y)<0.5 then return 0 end
    local dx,dy=sundir(x,y)
    if m:at(x+w*dx,y+w*dy)<0.5 then return 1 end
    if both and m:at(x-w*0.6*dx,y-w*0.6*dy)<0.5 then return 0.6 end
    return 0
  end)
end
-- golden-angle scale plates over a blob on the spine: a bronze touch, then a dark shadow touch on its far side
function plates_on_blob(t,len,wid,s,n,piles,size,seed,clipm)
  local nx,ny=-SV[2],SV[1]
  local c=spt(s or 0,t)
  local b=brush{kind="round",width=size,stiffness=0.4}
  local d=brush{kind="round",width=size*0.75,stiffness=0.4}
  local pts={}
  for i=1,n do
    local r=math.sqrt((i-0.5)/n)*0.92
    local a=i*2.399963+(seed or 0)
    local lx,ly=len/2*r*math.cos(a), wid/2*r*math.sin(a)
    local ox,oy=lx*SV[1]+ly*nx, lx*SV[2]+ly*ny
    local x,y=c[1]+ox,c[2]+oy
    local sx,sy=sundir(x,y)
    local face=(ox*sx+oy*sy)/(math.max(len,wid)/2)
    pts[#pts+1]={x,y,face,a,sx,sy,r}
  end
  for _,q in ipairs(pts) do
    local p=piles[q[3]>0.4 and 3 or (q[3]>-0.15 and 2 or 1)]
    b:reload(p,0.55)
    local k=1-0.45*q[7]^2
    b:touch(q[1],q[2],{pressure=rand(0.8,1)*k,drag={q[5]*1.2,q[6]*1.2},angle=q[4],clip=clipm})
  end
  for _,q in ipairs(pts) do
    d:reload(piles[0] or piles.dark,0.5)
    local k=1-0.45*q[7]^2
    d:touch(q[1]-q[5]*size*0.45*k,q[2]-q[6]*size*0.45*k,{pressure=rand(0.7,0.9)*k,angle=q[4],clip=clipm})
  end
end
-- graded rim: 1 at a sun-facing edge, falling to 0 at wmax inside the shape (measured toward the sun)
function rimgrad(m,wmax,bb,steps)
  steps=steps or 8
  return mask(function(x,y)
    if x<bb[1] or x>bb[3] or y<bb[2] or y>bb[4] then return 0 end
    if m:at(x,y)<0.5 then return 0 end
    local dx,dy=sundir(x,y)
    for k=1,steps do
      local d=wmax*k/steps
      if m:at(x+d*dx,y+d*dy)<0.5 then return 1-(k-1)/steps end
    end
    return 0
  end)
end
local bb={480,190,960,560}
local G=rimgrad(SP.all,9,bb,12)
local brk=noise{seed=5,period=18,octaves=3}
RIM_hot=G:band(0.8,1.01,0.05)*mask(function(x,y) return smoothstep(-0.5,0.1,brk(x,y)) end)
RIM_warm=G:band(0.25,0.85,0.08)
rim_gold=pile{{"lead white",3},{"cadmium yellow",1},{"chrome yellow",0.5}}
rim_orange=pile{{"Mars orange",1},{"burnt sienna",1},{"cadmium red",0.4},medium=0.3}
local ang=function(x,y) local sx,sy=sundir(x,y); return math.atan(sy,sx)+math.pi/2 end
work(RIM_warm,{hand="detail",pile=rim_orange,coverage=2.2,fill=true,tool={kind="round",width=2.4,point=0.3},angle=ang,load=0.7})
blend(RIM_warm,{tool={kind="badger",width=6}})
work(RIM_hot,{hand="detail",pile=rim_gold,coverage=3,fill=true,tool={kind="round",width=1.6,point=0.6},angle=ang})

--@ chunk 17
-- windows on the habitat ring: rows across the visible band, uneven golden-ratio spacing; a few clusters lit
local phi=0.6180339887
local litn=noise{seed=77,period=70,octaves=2}
win_lit=pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.3}}
win_warm=pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}
win_dead=pile{{"bone brown",2},{"burnt sienna",1}}
local wb=brush{kind="round",width=1.5,stiffness=0.5}
local okm=SP.ring:shrink(1.3)-(SP.all-SP.ring):grow(1)-SP.spokes:grow(1)
local placed={}
local cell={}
local function free(x,y)
  local kx,ky=math.floor(x/3),math.floor(y/3)
  for i=-1,1 do for j=-1,1 do local c=cell[(kx+i)..","..(ky+j)]
    if c then for _,q in ipairs(c) do if (q[1]-x)^2+(q[2]-y)^2<2.6^2 then return false end end end end end
  return true
end
local function put(x,y) local k=math.floor(x/3)..","..math.floor(y/3); cell[k]=cell[k] or {}; table.insert(cell[k],{x,y}) end
local n_lit,n_all=0,0
local ri=0
for _,sc in ipairs({1.0-0.012,1-RT+0.012}) do
 for off=-RW/2+2,RW/2-2,3.6 do
  ri=ri+1
  local a=rand(0,0.05)
  local i=0
  while a<2*math.pi do
    i=i+1
    local p=ringpt(a,sc,off)
    if okm:at(p[1],p[2])>0.5 and free(p[1],p[2]) and rand()>0.06 then
      put(p[1],p[2])
      local v=litn(p[1],p[2])
      local pl
      if v>0.3 then pl=(rand()<0.7) and win_lit or win_warm; n_lit=n_lit+1
      elseif rand()<0.03 then pl=win_warm; n_lit=n_lit+1
      else pl=win_dead end
      wb:reload(pl,0.6)
      wb:touch(p[1],p[2],{pressure=rand(0.55,0.8)})
      n_all=n_all+1
    end
    a=a+0.019*(0.75+0.5*((i*phi)%1))
  end
 end
end
print(n_lit,n_all)

--@ chunk 18
print(wait(3*24*60))
local disc=ellipse(cx,cy,R,R)
-- the far end of the spine, swallowed by glare: a veil that thickens toward the far end
local far=SP.all*mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(95,245,t) end)
veil=pile{{"lead white",4},{"lemon chrome",0.6},{"cadmium yellow",0.4},medium=0.45}
work(far,{hand="scumble",pile=veil,coverage=1.6,clip=SP.all:grow(1.5),tool={kind="filbert",width=4},load_at=function(x,y) return 0.15+0.6*far:at(x,y) end})
-- halation: where the silhouette lies over the disc, the glare eats its edges
local edge=(SP.all-SP.all:shrink(3.2))*disc:shrink(4)
local hal=pile{{"lead white",5},{"lemon chrome",1},medium=0.3}
work(edge,{hand="detail",pile=hal,coverage=0.9,load=0.35,tool={kind="round",width=1.8,point=0.4}})

--@ chunk 19
local disc=ellipse(cx,cy,R,R)
local zone=((SP.all:grow(2.5)-SP.all:shrink(4.5))*disc:shrink(4))
blend(zone,{tool={kind="badger",width=5}})

--@ chunk 20
print(wait(4*24*60))
local disc=ellipse(cx,cy,R,R)
local farT=mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t<108 and 1 or 0 end)
-- restore the disc around the silhouette (outside it)
local outside=(SP.all:grow(4.5)-SP.all)*disc:shrink(3)
work(outside,{hand="detail",pile=sun_white,coverage=4,fill=true,clip=outside,tool={kind="round",width=2.4}})
-- restore the dark inside the silhouette edge (not the far end, which is repainted separately)
local inside=(SP.all-SP.all:shrink(5))*disc:shrink(3)*farT
work(inside,{hand="detail",pile=sdark,coverage=4,fill=true,clip=SP.all,tool={kind="round",width=2.0}})

--@ chunk 21
local function tband(a,b) return mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(a-6,a+6,t)*(1-smoothstep(b-6,b+6,t)) end) end
local FS=SP.all*tband(100,300)
far1=pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
far2=pile{{"burnt sienna",2},{"bone brown",1},{"yellow ochre",1},{"lead white",0.6}}
far3=pile{{"yellow ochre",1},{"burnt sienna",1},{"lead white",1.6},{"cadmium yellow",0.3}}
local tl={tool={kind="round",width=2.4},hand="detail",coverage=4,fill=true,clip=SP.all,angle=0.6}
local function go(m,p) local o={} for k,v in pairs(tl) do o[k]=v end o.pile=p; work(m,o) end
go(SP.all*tband(100,152),far1)
go(SP.all*tband(148,198),far2)
go(SP.all*tband(194,300),far3)
blend(FS,{tool={kind="badger",width=10},angle=0.6})

--@ chunk 22
function limbpt(th,h) return {cx+(R+h)*math.cos(th), cy+(R+h)*math.sin(th)} end
-- one prominence: strands looping from the limb at th1 to th2, rising h units; feet sink a little into the limb
function prominence(th1,th2,h,strands,piles,seed,width)
  local nz=noise{seed=seed,period=30,octaves=3}
  local b=brush{kind="round",width=width or 3,point=0.15,stiffness=0.3}
  for s=1,strands do
    local a1=th1+rand(-0.012,0.012); local a2=th2+rand(-0.012,0.012)
    local hh=h*rand(0.6,1.08)
    local pts={}
    for i=0,24 do
      local f=i/24
      local th=lerp(a1,a2,f)
      local lift=hh*math.sin(math.pi*f)^0.8 - 4
      local p=limbpt(th,lift)
      local j=nz(p[1]*1.3+s*17,p[2]*1.3)*h*0.12
      pts[#pts+1]={p[1]+j*math.cos(th+1.57),p[2]+j*math.sin(th+1.57)}
    end
    b:reload(piles[1+(s-1)%#piles],rand(0.5,0.8))
    b:stroke(pts,{pressure={rand(0.4,0.7),rand(0.2,0.5)},swell={0.6,1,0.8,1.1,0.5},ramps={0.15,0.3}})
  end
end
-- a flame tongue/spray: strands leaning out from the limb
function spray(th,h,lean,strands,piles,seed,width)
  local nz=noise{seed=seed,period=25,octaves=3}
  local b=brush{kind="round",width=width or 2.5,point=0.7,stiffness=0.3}
  for s=1,strands do
    local a=th+rand(-0.02,0.02); local hh=h*rand(0.4,1)
    local pts={}
    for i=0,16 do local f=i/16
      local p=limbpt(a+lean*f*f+rand(-0.002,0.002), -3+hh*f)
      local j=nz(p[1]+s*31,p[2])*hh*0.15*f
      pts[#pts+1]={p[1]+j*math.cos(a+1.57),p[2]+j*math.sin(a+1.57)} end
    b:reload(piles[1+(s-1)%#piles],rand(0.4,0.7))
    b:stroke(pts,{pressure={0.7,0},ramps={0.1,0.6}})
  end
end
function arch_pts(th1,th2,h,n)
  local pts={}
  for i=0,(n or 30) do local f=i/(n or 30); pts[#pts+1]=limbpt(lerp(th1,th2,f), h*math.sin(math.pi*f)^0.8-4) end
  return pts
end
local disc=ellipse(cx,cy,R,R)
pr_gl=pile{{"rose madder",1.5},{"vermilion",0.6},{"cadmium red",0.3},medium=0.7}
pr_red=pile{{"cadmium red",1},{"vermilion",1},{"rose madder",0.5},medium=0.35}
pr_or=pile{{"vermilion",1},{"Mars orange",1},{"cadmium yellow",0.4},medium=0.3}
pr_hot=pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.3}}
function prom_body(th1,th2,h,n,w)
  local fb=brush{kind="filbert",width=w,stiffness=0.3}
  for s=1,n do
    local ap=arch_pts(th1+rand(-0.01,0.01),th2+rand(-0.01,0.01),h*rand(0.75,1.05),30)
    fb:reload(pr_gl,rand(0.3,0.5))
    fb:stroke(ap,{pressure={0.5,0.3},swell={0.5,1,1.1,0.9,0.4},ramps={0.1,0.2}})
  end
end
local function archzone(th1,th2,h,w)
  local ap=arch_pts(th1,th2,h,30); local aw={} for i=1,#ap do aw[i]=w*0.4+w*math.sin(math.pi*(i-1)/(#ap-1)) end
  return ribbon(ap,aw)-disc
end
-- the big loop, upper right
prom_body(-1.93,-1.765,74,5,9)
blend(archzone(-1.93,-1.765,74,22),{tool={kind="badger",width=12}})
prominence(-1.925,-1.77,76,7,{pr_red,pr_or},45,3.0)
prominence(-1.90,-1.795,58,3,{pr_or,pr_hot},42,1.4)
-- a low, torn loop at the bottom of the limb
prom_body(-2.86,-2.77,34,4,7)
blend(archzone(-2.86,-2.77,34,14),{tool={kind="badger",width=10}})
prominence(-2.855,-2.775,36,5,{pr_red,pr_or},47,2.4)

--@ chunk 23
local function feet(th,n,spread)
  local b=brush{kind="round",width=3,point=0.2,stiffness=0.3}
  for i=1,n do local a=th+rand(-spread,spread)
    b:reload((i%2==0) and pr_or or pr_red,0.6)
    b:stroke({limbpt(a,8),limbpt(a+rand(-0.004,0.004),-4),limbpt(a+rand(-0.006,0.006),-15)},{pressure={0.6,0.1},ramps={0.1,0.5}})
  end
end
feet(-1.925,6,0.008); feet(-1.77,6,0.008)
-- re-form the low loop into a full arch whose feet stand in the limb
prom_body(-2.885,-2.745,44,4,8)
prominence(-2.88,-2.75,46,6,{pr_red,pr_or},48,2.6)
feet(-2.88,5,0.008); feet(-2.75,5,0.008)

--@ chunk 24
print(wait(3*24*60))
local function archzone(th1,th2,h,w)
  local ap=arch_pts(th1,th2,h,30); local aw={} for i=1,#ap do aw[i]=w*0.4+w*math.sin(math.pi*(i-1)/(#ap-1)) end
  return ribbon(ap,aw)
end
PROM=(archzone(-1.93,-1.765,76,30)+archzone(-2.885,-2.745,46,26)):grow(4)
local bz=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; if d< -14 or d>55 then return 0 end; return 1-smoothstep(0,55,d) end)
local keep=SP.all:grow(3)+PROM
local zone=bz-keep
bloom=pile{{"lead white",6},{"lemon chrome",1},{"cadmium yellow",0.3},medium=0.5}
work(zone,{hand="glaze",pile=bloom,coverage=1.8,angle=tang,clip=zone:grow(10)-keep,load_at=function(x,y) return 0.1+0.8*bz:at(x,y)^1.5 end})
blend(zone:grow(10)-keep,{angle=tang})

--@ chunk 25
print(wait(5*24*60)); local p=limbpt(-1.85,60); print(drying(p[1],p[2])); p=limbpt(-2.8,30); print(drying(p[1],p[2])); print(drying(900,300))

--@ chunk 26
local bz=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; if d< -20 or d>90 then return 0 end; return 1-smoothstep(-5,90,d) end)
bloom2=pile{{"lead white",6},{"lemon chrome",1},{"cadmium yellow",0.4},medium=0.65}
work(bz,{hand="glaze",pile=bloom2,coverage=1.1,angle=tang,clip=-(SP.all:grow(1.5)),length={60,160},load_at=function(x,y) return 0.05+0.55*bz:at(x,y)^1.3 end})

--@ chunk 27
local function archzone(th1,th2,h,w)
  local ap=arch_pts(th1,th2,h,30); local aw={} for i=1,#ap do aw[i]=w*0.4+w*math.sin(math.pi*(i-1)/(#ap-1)) end
  return ribbon(ap,aw)
end
local z=(archzone(-2.885,-2.745,46,26):grow(6)+ellipse(588,455,22,30)):roughen(5,30,9)-SP.all:grow(2)
local gold=pile{{"lead white",2},{"cadmium yellow",2},{"chrome yellow",1},{"Mars orange",0.3}}
work(z,{hand="body",pile=gold,coverage=3.5,fill=true,angle=tang,edge="soft",clip=-(SP.all:grow(1.5))})
blend(z:grow(8)-SP.all:grow(2),{angle=tang})

--@ chunk 28
local area=ellipse(575,480,75,95)-SP.all:grow(2)
local function dz(a,b) return area*mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; return (d>a and d<b) and 1 or 0 end) end
work(dz(38,120):roughen(6,40,2),{hand="body",pile=gl[3],coverage=1.6,angle=tang,load=0.5,clip=-(SP.all:grow(1.5))})
work(dz(-20,18):roughen(6,40,3),{hand="body",pile=bloom,coverage=1.6,angle=tang,load=0.5,clip=-(SP.all:grow(1.5))})
blend(area,{angle=tang,tool={kind="badger",width=30}})

--@ chunk 29
local ring=(ellipse(575,480,92,112)-ellipse(575,480,58,78))-SP.all:grow(2)
blend(ring,{angle=tang,tool={kind="badger",width=24},clip=false})

--@ chunk 30
print(wait(5*24*60)); print(drying(640,450), drying(720,372), drying(600,500))

--@ chunk 31
FIX=rect(555,292,218,271)
local F=SP.all*FIX
work(F,{hand="detail",pile=sdark,coverage=4.5,fill=true,clip=F,tool={kind="round",width=2.4},angle=0.6})

--@ chunk 32
local bb={555,292,773,563}
local PL={pl_d,pl_m,pl_l,dark=pl_dk}
local PD={pl_sd,pl_d,pl_m,dark=pl_dk}
plates_on_blob(-120,34,42,-4,22,PL,5,2,SP.t2*FIX)
plates_on_blob(-116,26,26,20,11,PL,4.5,3,SP.t2b*FIX)
plates_on_blob(-84,22,34,0,12,PL,4.5,4,SP.t3*FIX)
plates_on_blob(0,38,84,0,34,PD,5.5,5,SP.hub*FIX)
plates_on_blob(72,62,36,0,26,PD,5,6,SP.m1*FIX)
local G=rimgrad(SP.all,9,bb,12)
local brk=noise{seed=5,period=18,octaves=3}
local hot=G:band(0.8,1.01,0.05)*mask(function(x,y) return smoothstep(-0.5,0.1,brk(x,y)) end)
local warm=G:band(0.25,0.85,0.08)
local ang=function(x,y) local sx,sy=sundir(x,y); return math.atan(sy,sx)+math.pi/2 end
work(warm,{hand="detail",pile=rim_orange,coverage=2.2,fill=true,tool={kind="round",width=2.4,point=0.3},angle=ang,load=0.7})
blend(warm,{tool={kind="badger",width=6}})
work(hot,{hand="detail",pile=rim_gold,coverage=3,fill=true,tool={kind="round",width=1.6,point=0.6},angle=ang})

--@ chunk 33
local m=SP.hub*FIX; print(m:at(720,372), SP.hub:at(720,372), FIX:at(720,372), pl_d, rim_gold)

--@ chunk 34
print(wait(8*24*60)); print(drying(720,372), drying(640,450))

--@ chunk 35
local PL={pl_d,pl_m,pl_l,dark=pl_dk}
local PD={pl_sd,pl_d,pl_m,dark=pl_dk}
plates_on_blob(-120,34,42,-4,22,PL,5,2,SP.t2*FIX)
plates_on_blob(-116,26,26,20,11,PL,4.5,3,SP.t2b*FIX)
plates_on_blob(-84,22,34,0,12,PL,4.5,4,SP.t3*FIX)
plates_on_blob(0,38,84,0,34,PD,5.5,5,SP.hub*FIX)
plates_on_blob(72,62,36,0,26,PD,5,6,SP.m1*FIX)
-- windows on the habitat ring: rows across the visible band, uneven golden-ratio spacing; a few clusters lit
local phi=0.6180339887
local litn=noise{seed=77,period=70,octaves=2}
win_lit=pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.3}}
win_warm=pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}
win_dead=pile{{"bone brown",2},{"burnt sienna",1}}
local wb=brush{kind="round",width=1.5,stiffness=0.5}
local okm=(SP.ring:shrink(1.3)-(SP.all-SP.ring):grow(1)-SP.spokes:grow(1))*FIX:shrink(1)
local placed={}
local cell={}
local function free(x,y)
  local kx,ky=math.floor(x/3),math.floor(y/3)
  for i=-1,1 do for j=-1,1 do local c=cell[(kx+i)..","..(ky+j)]
    if c then for _,q in ipairs(c) do if (q[1]-x)^2+(q[2]-y)^2<2.6^2 then return false end end end end end
  return true
end
local function put(x,y) local k=math.floor(x/3)..","..math.floor(y/3); cell[k]=cell[k] or {}; table.insert(cell[k],{x,y}) end
local n_lit,n_all=0,0
local ri=0
for _,sc in ipairs({1.0-0.012,1-RT+0.012}) do
 for off=-RW/2+2,RW/2-2,3.6 do
  ri=ri+1
  local a=rand(0,0.05)
  local i=0
  while a<2*math.pi do
    i=i+1
    local p=ringpt(a,sc,off)
    if okm:at(p[1],p[2])>0.5 and free(p[1],p[2]) and rand()>0.06 then
      put(p[1],p[2])
      local v=litn(p[1],p[2])
      local pl
      if v>0.3 then pl=(rand()<0.7) and win_lit or win_warm; n_lit=n_lit+1
      elseif rand()<0.03 then pl=win_warm; n_lit=n_lit+1
      else pl=win_dead end
      wb:reload(pl,0.6)
      wb:touch(p[1],p[2],{pressure=rand(0.55,0.8)})
      n_all=n_all+1
    end
    a=a+0.019*(0.75+0.5*((i*phi)%1))
  end
 end
end
print(n_lit,n_all)

--@ chunk 36
local disc=ellipse(cx,cy,R,R)
local function arc(th1,th2,r,n) local p={} for i=0,n do p[#p+1]={cx+r*math.cos(lerp(th1,th2,i/n)), cy+r*math.sin(lerp(th1,th2,i/n))} end return p end
local avoid=SP.all:grow(2.5)
-- the limb: a pale-gold band just inside the edge, laid crisp
local band=(disc-disc:shrink(9))*(mask(function(x,y) return 1 end))-avoid
local limbgold=pile{{"lead white",5},{"lemon chrome",1},{"cadmium yellow",1.2}}
work(band,{hand="detail",pile=limbgold,coverage=3.5,fill=true,clip=band,angle=tang,tool={kind="round",width=2.4}})
-- the chromosphere: a thin fire line outside it, broken in places by the glare
local chrom=pile{{"cadmium red",1},{"vermilion",1},{"Mars orange",0.6}}
local cb=brush{kind="round",width=2.2,point=0.3,stiffness=0.4}
for _,seg in ipairs({{-3.0,-2.66},{-2.13,-1.58}}) do
  local th=seg[1]
  while th<seg[2] do
    local len=rand(0.03,0.08)
    local p=arc(th,math.min(th+len,seg[2]),R+1.6,8)
    local ok=true
    for _,q in ipairs(p) do if avoid:at(q[1],q[2])>0.2 then ok=false end end
    if ok then cb:reload(chrom,rand(0.45,0.7)); cb:stroke(p,{pressure={rand(0.4,0.75),rand(0.3,0.7)},ramps={0.2,0.3},clip=-avoid}) end
    th=th+len+rand(0.0,0.012)
  end
end

--@ chunk 37
local disc=ellipse(cx,cy,R,R)
local face=disc:shrink(12)-SP.all:grow(3)
-- granulation: a faint mottle of slightly warmer cream
local gran=pile{{"lead white",8},{"lemon chrome",1},{"yellow ochre",0.35}}
stipple(face,{pile=gran,width=2.6,coverage=0.55,pressure={0.3,0.55},cluster={0.6,6},feather=0.3,dips={30,0.5,0.5},clip=face})

--@ chunk 38
function rell(x,y,a,b,ang,rough,seed)
  local pts={} for i=0,35 do local t=2*math.pi*i/36; local u,v=a*math.cos(t),b*math.sin(t)
    pts[#pts+1]={x+u*math.cos(ang)-v*math.sin(ang), y+u*math.sin(ang)+v*math.cos(ang)} end
  local m=poly(pts,true); if rough then m=m:roughen(rough,6,seed or 1) end; return m
end
local penum=pile{{"burnt sienna",1},{"yellow ochre",1.2},{"lead white",1.2},{"Mars orange",0.3}}
local umbra=pile{{"bone brown",2},{"burnt sienna",1},{"Mars red",0.3}}
local spots={{935,395,6.5},{949,404,3.6},{923,386,2.8},{962,413,2.2},{913,379,1.6},{878,508,4.2},{886,503,1.8}}
for i,s in ipairs(spots) do
  local dx,dy=s[1]-cx,s[2]-cy; local ang=math.atan(dy,dx)  -- radial direction
  local fs=math.sqrt(math.max(0.05,1-((dx*dx+dy*dy)/(R*R))))  -- foreshortening across the radius
  local P=rell(s[1],s[2],s[3]*fs*1.0,s[3]*1.15,ang,s[3]*0.25,i)
  local U=rell(s[1]+rand(-0.4,0.4),s[2]+rand(-0.4,0.4),s[3]*fs*0.45,s[3]*0.5,ang+rand(-0.3,0.3),s[3]*0.12,i+20)
  work(P,{hand="detail",pile=penum,coverage=3,fill=true,clip=P,tool={kind="round",width=1.4},angle=ang})
  work(U,{hand="detail",pile=umbra,coverage=3.5,fill=true,clip=U,tool={kind="round",width=1.0},angle=ang})
end

--@ chunk 39
local tf=mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(110,250,t) end)
local zone=SP.all:grow(4)*tf
veil2=pile{{"lead white",8},{"lemon chrome",1},medium=0.55}
work(zone,{hand="glaze",tool={kind="filbert",width=8},length={20,60},pile=veil2,coverage=1.6,angle=0.6,clip=SP.all:grow(4)*mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t>100 and 1 or 0 end),load_at=function(x,y) return 0.15+0.6*tf:at(x,y) end})

--@ chunk 40
local z=SP.all:grow(4)*mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t>104 and 1 or 0 end); blend(z,{tool={kind="badger",width=10},angle=0.6}); blend(z,{tool={kind="badger",width=10},angle=0.6+1.57})

--@ chunk 41
-- apertures along the near spine: rows spaced by golden-ratio steps, a few lit
local phi=1.6180339887
local wb=brush{kind="round",width=1.3,stiffness=0.5}
local trunkonly=(SP.trunk1+SP.collar1+SP.collar2+SP.maw):shrink(1.5)-(SP.t1+SP.t1b+SP.t2+SP.t2b+SP.t3):grow(1)
local n,l=0,0
for _,s in ipairs({-8,-3,2,7}) do
  local t=-232+rand(0,3); local k=0
  while t<-22 do
    k=k+1
    local p=spt(s,t)
    if trunkonly:at(p[1],p[2])>0.5 then
      local lit=rand()<0.18
      wb:reload(lit and win_lit or win_dead,0.6)
      wb:touch(p[1],p[2],{pressure=rand(0.5,0.75)})
      n=n+1; if lit then l=l+1 end
    end
    t=t+3.2*(1+0.35*((k*phi)%1))
  end
end
print(n,l)

--@ chunk 42
local PL={pl_d,pl_m,pl_l,dark=pl_dk}; plates_on_blob(-158,30,30,-24,14,PL,5,11,SP.t1b); plates_on_blob(-120,34,42,-4,22,PL,5,12,SP.t2); plates_on_blob(-116,26,26,20,11,PL,4.5,13,SP.t2b)

--@ chunk 43
ray_p=pile{{"lead white",5},{"lemon chrome",1},{"cadmium yellow",0.6},medium=0.6}
function corona_ray(th,len,w,bend,load)
  local b=brush{kind="filbert",width=w,stiffness=0.25}
  local pts={}
  for i=0,12 do local f=i/12; local r=R-6+len*f; local a=th+bend*f*f
    pts[#pts+1]={cx+r*math.cos(a), cy+r*math.sin(a)} end
  b:reload(ray_p,load or 0.5)
  b:stroke(pts,{pressure={0.55,0.02},ramps={0.05,0.7},clip=-(SP.all:grow(2.5))})
end
corona_ray(-1.70,300,10,0.03,0.6)
corona_ray(-2.32,420,9,-0.04,0.6)
corona_ray(-2.95,260,8,0.02,0.5)

--@ chunk 44
local function raypts(th,len,bend) local pts={} for i=0,12 do local f=i/12; local r=R-6+len*f; local a=th+bend*f*f; pts[#pts+1]={cx+r*math.cos(a), cy+r*math.sin(a)} end return pts end
local z=(ribbon(raypts(-2.32,430,-0.04),{40,36,32,28,26,24,22,20,18,16,14,12,10})+ribbon(raypts(-2.95,270,0.02),{30,28,26,24,22,20,18,16,14,12,10,9,8})+ribbon(raypts(-1.70,310,0.03),{30,28,26,24,22,20,18,16,14,12,10,9,8}))-SP.all:grow(3)
blend(z,{tool={kind="badger",width=26},angle=function(x,y) return math.atan(y-cy,x-cx) end})
blend(z,{tool={kind="badger",width=26},angle=function(x,y) return math.atan(y-cy,x-cx)+1.4 end})

--@ chunk 45
ray_p=pile{{"lead white",5},{"lemon chrome",1},{"cadmium yellow",0.6},medium=0.6}
function corona_ray(th,len,w,bend,load)
  local b=brush{kind="filbert",width=w,stiffness=0.25}
  local pts={}
  for i=0,12 do local f=i/12; local r=R-6+len*f; local a=th+bend*f*f
    pts[#pts+1]={cx+r*math.cos(a), cy+r*math.sin(a)} end
  b:reload(ray_p,load or 0.5)
  b:stroke(pts,{pressure={0.55,0.02},ramps={0.05,0.7},clip=-(SP.all:grow(2.5))})
end
local function raypts(th,len,bend) local pts={} for i=0,12 do local f=i/12; local r=R-6+len*f; local a=th+bend*f*f; pts[#pts+1]={cx+r*math.cos(a), cy+r*math.sin(a)} end return pts end
local rays={{-3.08,240,16,0.02,0.4},{-2.78,330,18,-0.03,0.45},{-2.05,380,16,0.035,0.45},{-1.90,250,14,-0.02,0.35},{-1.63,220,18,0.02,0.4},{-2.50,300,12,0.01,0.35}}
local z
for _,r in ipairs(rays) do
  corona_ray(r[1],r[2],r[3],r[4],r[5])
  local w={} for i=1,13 do w[i]=lerp(r[3]*3.2,r[3]*0.9,(i-1)/12) end
  local rz=ribbon(raypts(r[1],r[2]+20,r[4]),w)
  z = z and (z+rz) or rz
end
z=z-SP.all:grow(3)
blend(z,{tool={kind="badger",width=26},angle=function(x,y) return math.atan(y-cy,x-cx) end})
blend(z,{tool={kind="badger",width=26},angle=function(x,y) return math.atan(y-cy,x-cx)+1.4 end})

--@ chunk 46
local function raypts(th,len,bend) local pts={} for i=0,12 do local f=i/12; local r=R-6+len*f; local a=th+bend*f*f; pts[#pts+1]={cx+r*math.cos(a), cy+r*math.sin(a)} end return pts end
local rays={{-3.08,240,16,0.02},{-2.78,330,18,-0.03},{-2.05,380,16,0.035},{-1.90,250,14,-0.02},{-1.63,220,18,0.02},{-2.50,300,12,0.01},{-2.32,430,10,-0.04}}
local z
for _,r in ipairs(rays) do
  local w={} for i=1,13 do w[i]=lerp(r[3]*4.5,r[3]*2,(i-1)/12) end
  local rz=ribbon(raypts(r[1],r[2]+40,r[4]),w)
  z = z and (z+rz) or rz
end
z=z-SP.all:grow(3)
blend(z,{tool={kind="badger",width=40},angle=function(x,y) return math.atan(y-cy,x-cx)+0.7 end})
blend(z,{tool={kind="badger",width=40},angle=function(x,y) return math.atan(y-cy,x-cx) end})

--@ chunk 47
print(wait(6*24*60)); print(drying(330,440), drying(600,170), drying(780,60))

--@ chunk 48
local gz=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; if d<8 or d>520 then return 0 end; return smoothstep(8,40,d)*(1-smoothstep(300,520,d)) end)
local avoid=SP.all:grow(2.5)
warmgl=pile{{"Indian yellow",2},{"Mars orange",0.5},{"rose madder",0.2},medium=0.82}
work(gz-avoid,{hand="glaze",pile=warmgl,coverage=1.1,angle=tang,clip=-avoid,load_at=function(x,y) return 0.1+0.5*gz:at(x,y) end})
blend(mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; return (d>0 and d<560) and 1 or 0 end)-avoid,{angle=tang,tool={kind="badger",width=40}})

--@ chunk 49
print(wait(7*24*60)); print(drying(330,300), drying(600,170))

--@ chunk 50
local avoid=SP.all:grow(2.5)
local function raypts(th,len,bend,f0) local pts={} for i=0,12 do local f=(f0 or 0)+(1-(f0 or 0))*i/12; local r=R-6+len*f; local a=th+bend*f*f; pts[#pts+1]={cx+r*math.cos(a), cy+r*math.sin(a)} end return pts end
local rays={{-3.08,240,16,0.02},{-2.78,330,18,-0.03},{-2.05,380,16,0.035},{-1.90,250,14,-0.02},{-1.63,220,18,0.02},{-2.50,300,12,0.01},{-2.32,430,10,-0.04}}
-- beam tips: zones covering the outer half of each beam, a little past its end
local tips
for _,r in ipairs(rays) do
  local tz=ribbon(raypts(r[1],r[2]+45,r[4],0.55),r[3]*4.5)
  tips = tips and (tips+tz) or tz
end
local band=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; return smoothstep(260,340,d)*(1-smoothstep(470,540,d)) end)
local tipfade=mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; return smoothstep(150,330,d) end)
madgl=pile{{"rose madder",1.5},{"Mars red",0.6},{"bone brown",0.4},medium=0.8}
local zone=(band+tips*tipfade)-avoid
work(zone,{hand="glaze",pile=madgl,coverage=1.3,angle=tang,clip=-avoid,load_at=function(x,y) return 0.1+0.55*math.max(band:at(x,y),tips:at(x,y)*tipfade:at(x,y)) end})
blend(zone:grow(30)-avoid,{angle=tang,tool={kind="badger",width=40}})

--@ chunk 51
print(wait(7*24*60)); print(drying(330,300), drying(150,100))

--@ chunk 52
-- repaint the seamed tank cluster whole, then its plates
local T=SP.t2+SP.t2b
work(T,{hand="detail",pile=sdark,coverage=4.5,fill=true,clip=T,tool={kind="round",width=2.4}})
local PL={pl_d,pl_m,pl_l,dark=pl_dk}
plates_on_blob(-120,34,42,-4,24,PL,5,21,SP.t2)
plates_on_blob(-116,26,26,20,12,PL,4.5,23,SP.t2b)
-- seams across the ring band at uneven golden steps, as thin bronze lines
local phi=0.6180339887
local sb=brush{kind="round",width=1.1,point=0.4,stiffness=0.5}
local seam=pile{{"burnt sienna",2},{"bone brown",1},{"yellow ochre",0.5}}
local a=0.03; local k=0
local okm=SP.ring-(SP.all-SP.ring):grow(1.5)
while a<2*math.pi do
  k=k+1
  local p1=ringpt(a,1-0.004,-RW/2+1); local p2=ringpt(a,1-0.004,RW/2-1)
  local pm={(p1[1]+p2[1])/2,(p1[2]+p2[2])/2}
  if okm:at(pm[1],pm[2])>0.5 then
    sb:reload(seam,0.5)
    sb:stroke({p1,pm,p2},{pressure={0.5,0.4},clip=okm})
  end
  a=a+0.09*(0.6+0.8*((k*phi)%1))
end

--@ chunk 53
wait(9*24*60); local c=spt(-4,-120); print(drying(c[1],c[2])); local PL={pl_d,pl_m,pl_l,dark=pl_dk}; plates_on_blob(-120,34,42,-4,24,PL,5,21,SP.t2); plates_on_blob(-116,26,26,20,12,PL,4.5,23,SP.t2b)

--@ chunk 54
local darkzone=function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; return smoothstep(540,640,d) end
local starc=pile{{"lead white",4},{"cerulean blue",0.4}}
local starw=pile{{"lead white",4},{"yellow ochre",0.3}}
local starf=pile{{"lead white",1},{"ultramarine ash",1},{"bone brown",0.5}}
local tb=brush{kind="round",width=1.0,point=0.6,stiffness=0.5}
local cl=worley{seed=9,period=120}
local n=0
for i=1,900 do
  local x,y=rand(4,996),rand(4,558)
  local dz=darkzone(x,y)
  local c=cl:at(x,y)
  if dz>0.3 and rand()<0.12*dz then
    local r=rand()
    local pl= r<0.75 and starf or (r<0.9 and starw or starc)
    tb:reload(pl,0.5)
    tb:touch(x,y,{pressure=(r<0.75) and rand(0.15,0.3) or rand(0.3,0.5)})
    n=n+1
  end
end
print(n)
-- three brighter stars, with a breath of halo
for _,s in ipairs({{88,372},{402,58},{196,505}}) do
  local hb=brush{kind="round",width=3.2,stiffness=0.3}
  hb:reload(pile{{"lead white",1},{"cobalt blue",0.5},medium=0.7},0.3)
  hb:touch(s[1],s[2],{pressure=0.35})
  tb:reload(starc,0.6); tb:touch(s[1],s[2],{pressure=0.55})
end

--@ chunk 55
local starc=pile{{"lead white",4},{"cerulean blue",0.4}}
local starf=pile{{"lead white",2},{"ultramarine ash",1}}
local tb=brush{kind="round",width=1.6,point=0.3,stiffness=0.5}
local pts={{42,428},{61,441},{118,470},{25,520},{150,395},{70,300},{232,540},{12,250},{168,530},{96,512},{30,170},{205,450},{55,92},{128,40},{300,24},{22,40}}
for i,p in ipairs(pts) do tb:reload(i%4==0 and starc or starf,0.6); tb:touch(p[1],p[2],{pressure=(i%4==0) and 0.6 or rand(0.3,0.45)}) end
-- CUCULUS: the seed, a cold white spark with a faint trail, inbound toward the station
local trail=pile{{"lead white",2},{"cerulean blue",0.6},medium=0.6}
local rb=brush{kind="round",width=1.4,point=0.8,stiffness=0.4}
rb:reload(trail,0.4)
rb:stroke({{214,486},{258,462},{296,441}},{pressure={0.02,0.35},ramps={0.6,0.05}})
rb:reload(pile{{"lead white",4},{"cerulean blue",0.2}},0.8)
rb:touch(297,440,{pressure=0.8})

--@ chunk 56
print(wait(3*24*60))
local b=brush{kind="filbert",width=5,stiffness=0.3}
local loc=pile{{"Mars red",1},{"rose madder",0.6},{"bone brown",0.6},medium=0.55}
for i=0,9 do local f=i/9
  local x=lerp(212,272,f); local y=lerp(487,454,f)
  b:reload(loc,0.55*(1-f)+0.1)
  b:touch(x,y,{pressure=0.4,drag={4,-2.2}})
end

--@ chunk 57
local b=brush{kind="filbert",width=4,stiffness=0.3}
local loc=pile{{"Mars red",1},{"rose madder",0.4},{"bone brown",0.8},{"burnt sienna",0.4},medium=0.25}
b:reload(loc,0.8); b:stroke({{210,488},{240,471},{262,459}},{pressure={0.7,0.3},ramps={0.05,0.6}})
b:reload(loc,0.5); b:stroke({{230,477},{260,460},{280,450}},{pressure={0.4,0.05},ramps={0.05,0.8}})

--@ chunk 58
local z=ribbon({{205,491},{245,469},{285,447}},{12,10,7}); blend(z,{tool={kind="badger",width=14},angle=-0.5}); blend(z,{tool={kind="badger",width=14},angle=1.0})

--@ chunk 59
print(wait(4*24*60))
print(drying(780,80),drying(400,440),drying(300,200),drying(880,470))
local avoid=SP.all:grow(2.5)
local function dband(a,b,s) return mask(function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2)-R; return smoothstep(a-s,a+s,d)*(1-smoothstep(b-s,b+s,d)) end) end
-- golden glaze over the inner glow and the rays
local g1=dband(10,300,40)-avoid
goldgl=pile{{"Indian yellow",2},{"cadmium yellow",0.5},{"rose madder",0.25},medium=0.85}
work(g1,{hand="glaze",pile=goldgl,coverage=1.2,angle=tang,clip=-avoid,load_at=function(x,y) return 0.15+0.45*g1:at(x,y) end})
-- madder glaze over the olive transition band
local g2=dband(330,560,50)-avoid
madgl2=pile{{"rose madder",2},{"Mars red",0.5},{"magenta",0.3},medium=0.85}
work(g2,{hand="glaze",pile=madgl2,coverage=1.2,angle=tang,clip=-avoid,load_at=function(x,y) return 0.15+0.45*g2:at(x,y) end})
blend((g1+g2):grow(10)-avoid,{angle=tang,tool={kind="badger",width=40}})

--@ chunk 60
local disc=ellipse(cx,cy,R,R)
local spots=ellipse(938,398,34,24)+ellipse(880,506,12,10)
local avoid=SP.all:grow(3)+spots
zinc_core=pile{{"zinc white",6},{"lemon chrome",0.2}}
local core=(disc:shrink(60):soften(30))-avoid
work(core,{hand="broad",pile=zinc_core,coverage=4,fill=true,angle=tang,clip=disc:shrink(40)-avoid,edge="soft"})
blend(disc:shrink(30)-avoid,{angle=tang,tool={kind="badger",width=40}})

--@ chunk 61
local spots={{935,395,6.5},{949,404,3.6},{923,386,2.8},{962,413,2.2},{913,379,1.6},{878,508,4.2},{886,503,1.8}}
local tight
for _,s in ipairs(spots) do local e=ellipse(s[1],s[2],s[3]*0.9+1.5,s[3]*1.2+1.5); tight = tight and (tight+e) or e end
local zone=(ellipse(938,398,40,30)+ellipse(880,506,16,14))-tight-SP.all:grow(3)
work(zone,{hand="detail",pile=zinc_core,coverage=4,fill=true,clip=zone,tool={kind="round",width=2}})
blend(zone:grow(6)-tight-SP.all:grow(3),{tool={kind="badger",width=10}})

--@ chunk 62
local disc=ellipse(cx,cy,R,R)
local spots={{935,395,6.5},{949,404,3.6},{923,386,2.8},{962,413,2.2},{913,379,1.6},{878,508,4.2},{886,503,1.8}}
local tight
for _,s in ipairs(spots) do local e=ellipse(s[1],s[2],s[3]*0.9+0.8,s[3]*1.2+0.8); tight = tight and (tight+e) or e end
local inner=disc:shrink(40)
local halo=((SP.all:grow(3.5)-SP.all:grow(0.6))+(ellipse(938,398,46,36)+ellipse(880,506,22,20)-tight))*inner
work(halo,{hand="detail",pile=zinc_core,coverage=4,fill=true,clip=halo,tool={kind="round",width=1.8}})
local bz=inner-tight-SP.all:grow(0.6)
blend(bz,{tool={kind="badger",width=30},angle=tang})
blend(bz,{tool={kind="badger",width=30},angle=function(x,y) return tang(x,y)+1.2 end})

--@ chunk 63
print(wait(8*24*60)); print(drying(900,450), drying(880,480), drying(950,300))

--@ chunk 64
local function tband(a,b) return mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(a-6,a+6,t)*(1-smoothstep(b-6,b+6,t)) end) end
local fa=pile{{"bone brown",2},{"burnt sienna",1.2},{"Mars red",0.2}}
local fb=pile{{"burnt sienna",2},{"bone brown",1},{"Mars orange",0.3},{"lead white",0.4}}
local fc=pile{{"burnt sienna",1.5},{"yellow ochre",1},{"lead white",1},{"Mars orange",0.4}}
local tl={tool={kind="round",width=2.2},hand="detail",coverage=4.5,fill=true,clip=SP.all,angle=0.6}
local function go(m,p) local o={} for k,v in pairs(tl) do o[k]=v end o.pile=p; work(m,o) end
go(SP.all*tband(100,160),fa)
go(SP.all*tband(155,205),fb)
go(SP.all*tband(200,300),fc)
blend(SP.all*tband(100,300),{tool={kind="badger",width=8},angle=0.6})

--@ chunk 65
local function tband(a,b) return mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(a-6,a+6,t)*(1-smoothstep(b-6,b+6,t)) end) end
local F=SP.all*tband(100,300)
work(F,{tool={kind="round",width=2.2},hand="detail",coverage=5,fill=true,clip=SP.all,angle=0.6,pile=sdark})

--@ chunk 66
print(wait(12*24*60))
local p=spt(0,170); print(drying(p[1],p[2]))
local bb={760,380,960,560}
local disc=ellipse(cx,cy,R,R)
local F=SP.all*mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t>100 and 1 or 0 end)
-- vault bay apertures: a row of small warm lights along each side of the vault, spaced by golden steps
local phi=0.6180339887
local wb=brush{kind="round",width=1.3,stiffness=0.5}
local k=0
for _,s in ipairs({-9,-4,4,9}) do
  local t=104+rand(0,2)
  while t<236 do
    k=k+1
    local q=spt(s,t)
    if F:shrink(1.6):at(q[1],q[2])>0.5 then
      local lit=rand()<0.22
      wb:reload(lit and win_warm or win_dead,0.6); wb:touch(q[1],q[2],{pressure=rand(0.5,0.7)})
    end
    t=t+3.4*(0.8+0.5*((k*phi)%1))
  end
end
-- glare eats the far end's edges: a thin cream rim around its outline, broken
local edge=(F-F:shrink(1.8))*mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(120,240,t) end)
work(edge,{hand="detail",pile=zinc_core,coverage=2,load=0.4,tool={kind="round",width=1.4,point=0.5},clip=F:grow(1)})

--@ chunk 67
print(wait(4*24*60))
local p=limbpt(-1.85,60); print(drying(p[1],p[2]))
local pr_deep=pile{{"cadmium red",1.2},{"rose madder",0.6},{"vermilion",0.6}}
prominence(-1.93,-1.765,78,9,{pr_deep,pr_red,pr_or},51,2.6)
prominence(-1.915,-1.78,64,5,{pr_or,pr_hot},52,1.5)
local function feet2(th,n,spread)
  local b=brush{kind="round",width=2.6,point=0.3,stiffness=0.3}
  for i=1,n do local a=th+rand(-spread,spread)
    b:reload((i%2==0) and pr_or or pr_deep,0.6)
    b:stroke({limbpt(a,10),limbpt(a+rand(-0.004,0.004),-2),limbpt(a+rand(-0.006,0.006),-8)},{pressure={0.6,0.1},ramps={0.1,0.5}})
  end
end
feet2(-1.93,5,0.007); feet2(-1.765,5,0.007)

--@ chunk 68
local nx,ny=-SV[2],SV[1]
local lb=brush{kind="round",width=1.0,point=0.5,stiffness=0.5}
local arcp=pile{{"burnt sienna",2},{"yellow ochre",0.8},{"bone brown",0.5}}
local M=SP.maw+SP.lip+SP.trunk1
-- growth ribs across the bell, spacing widening toward the mouth (geometric, ratio ~1.27)
local t=-212; local step=3.2
while t>-249 do
  local f=clamp((-t-214)/36,0,1)
  local w=lerp(30,66,f^0.45)*0.5-1.2
  local pts={}
  for i=0,10 do local u=-1+2*i/10; local bow=-(1-u*u)*w*0.16
    local c=spt(0,t+bow); pts[#pts+1]={c[1]+nx*u*w,c[2]+ny*u*w} end
  lb:reload(arcp,0.5)
  lb:stroke(pts,{pressure={0.45,0.35},clip=M:shrink(0.8)})
  t=t-step; step=step*1.27
end
-- the mouth's rim, nearly edge-on: a thin broken ellipse in hot bronze on its sun side
local hotb=pile{{"yellow ochre",1},{"cadmium yellow",0.6},{"lead white",0.8},{"burnt sienna",0.3}}
local mp={}
for i=0,40 do local a=-math.pi/2+math.pi*i/40; local c=spt(0,-249+4*math.cos(a)); mp[#mp+1]={c[1]+nx*35*math.sin(a),c[2]+ny*35*math.sin(a)} end
lb:reload(hotb,0.6)
lb:stroke(mp,{pressure={0.5,0.6},swell={0.3,1,1.2,0.6,1,0.4},clip=M:grow(1)})

--@ chunk 69
print(wait(3*24*60))
local hole=ellpoly(1-RT,-RW/2)*ellpoly(1-RT,RW/2)
local bb={560,200,860,540}
local W=10
local OTHER=SP.all-SP.ring
local face=mask(function(x,y)
  if x<bb[1] or x>bb[3] or y<bb[2] or y>bb[4] then return 0 end
  if SP.ring:at(x,y)<0.5 or OTHER:at(x,y)>0.5 then return 0 end
  local dx,dy=sundir(x,y)
  for k=1,10 do local d=W*k/10
    local px,py=x+d*dx,y+d*dy
    if SP.all:at(px,py)<0.5 then
      if hole:at(px,py)>0.5 then return 1-(k-1)/10 else return 0 end
    end
  end
  return 0
end)
print(face:area())
local brz_hot=pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",1},{"Mars orange",0.2}}
local brz_mid=pile{{"yellow ochre",1},{"burnt sienna",1},{"Mars orange",0.4},{"lead white",0.4}}
local brz_low=pile{{"burnt sienna",2},{"bone brown",1},{"Mars orange",0.3}}
local ang=function(x,y) local sx,sy=sundir(x,y); return math.atan(sy,sx)+math.pi/2 end
local o={hand="detail",coverage=3.5,fill=true,tool={kind="round",width=1.6,point=0.4},angle=ang,clip=SP.ring}
local function go(m,p) local q={} for k,v in pairs(o) do q[k]=v end q.pile=p; work(m,q) end
go(face:band(0.05,0.45,0.05),brz_low)
go(face:band(0.4,0.78,0.05),brz_mid)
go(face:band(0.75,1.01,0.03),brz_hot)
blend(face:grow(0.5)*SP.ring,{tool={kind="badger",width=4},angle=ang})
FACE=face

--@ chunk 70
print(wait(5*24*60))
local hot=FACE:band(0.8,1.01,0.03)
local brk=noise{seed=15,period=22,octaves=3}
hot=hot*mask(function(x,y) return smoothstep(-0.6,0.0,brk(x,y)) end)
local ang=function(x,y) local sx,sy=sundir(x,y); return math.atan(sy,sx)+math.pi/2 end
local fire=pile{{"lead white",3},{"cadmium yellow",1.2},{"chrome yellow",0.4}}
work(hot,{hand="detail",pile=fire,coverage=3.5,fill=true,tool={kind="round",width=1.4,point=0.6},angle=ang,clip=SP.ring})
-- a row of windows on the lit face, dark glass with a few warm
local wb=brush{kind="round",width=1.2,stiffness=0.5}
local glass=pile{{"bone brown",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
local a=0; local k=0; local phi=0.618034
local mid=FACE:band(0.35,0.7,0.02)
while a<2*math.pi do
  k=k+1
  for _,sc in ipairs({1-RT+0.006,1-RT+0.016}) do
    for _,off in ipairs({-RW/2+3,-RW/2+7,-RW/2+11,-RW/2+15,-RW/2+19}) do
      local p=ringpt(a,sc,off)
      if mid:at(p[1],p[2])>0.5 and rand()<0.5 then
        wb:reload(rand()<0.2 and win_lit or glass,0.6); wb:touch(p[1],p[2],{pressure=rand(0.45,0.65)})
      end
    end
  end
  a=a+0.022*(0.75+0.5*((k*phi)%1))
end

--@ chunk 71
local tf=function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return smoothstep(120,250,t) end
local a=spt(0,110); local b=spt(0,262)
local z=ribbon({a,spt(0,180),b},{20,30,38})
local veil3=pile{{"zinc white",6},{"lemon chrome",0.25},medium=0.75}
local vb=brush{kind="filbert",width=14,stiffness=0.25}
for i=1,7 do
  local s=rand(-8,8)
  vb:reload(veil3,0.35)
  vb:stroke({spt(s,130+rand(0,15)),spt(s*0.8,190),spt(s*0.6,262)},{pressure={0.1,0.55},ramps={0.5,0.1}})
end
blend(z,{tool={kind="badger",width=20},angle=0.6})

--@ chunk 72
print(wait(6*24*60))
local p=spt(0,180); print(drying(p[1],p[2]))
local z=SP.all:grow(2)*mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t>100 and 1 or 0 end)
local amber=pile{{"Indian yellow",2},{"burnt sienna",0.7},{"Mars orange",0.3},medium=0.7}
work(z,{hand="glaze",tool={kind="filbert",width=6},length={15,40},pile=amber,coverage=2,angle=0.6,clip=z})

--@ chunk 73
print(wait(5*24*60))
local p=spt(0,180); print(drying(p[1],p[2]))
local far=mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t>98 and 1 or 0 end)
local F=SP.all*far
local disc=ellipse(cx,cy,R,R)
-- restore the disc around it
local out=(SP.all:grow(5)-SP.all)*far*disc
work(out,{hand="detail",pile=zinc_core,coverage=4.5,fill=true,clip=out,tool={kind="round",width=2.2}})
-- the far spine, opaque dark again
local fdark=pile{{"bone black",1.5},{"burnt sienna",1.2},{"bone brown",1},{"ultramarine blue",0.4}}
work(F,{hand="detail",pile=fdark,coverage=5,fill=true,clip=F,tool={kind="round",width=2.2},angle=0.6})

--@ chunk 74
print(wait(8*24*60))
local p=spt(0,180); print(drying(p[1],p[2]))
local far=mask(function(x,y) local t=(x-SC[1])*SV[1]+(y-SC[2])*SV[2]; return t>98 and 1 or 0 end)
local F=SP.all*far
local bb={760,400,960,560}
local G=rimgrad(SP.all,6,bb,10)*far
local ang=function(x,y) local sx,sy=sundir(x,y); return math.atan(sy,sx)+math.pi/2 end
work(G:band(0.3,0.85,0.06),{hand="detail",pile=rim_orange,coverage=2,fill=true,tool={kind="round",width=1.8,point=0.3},angle=ang,load=0.6,clip=F})
work(G:band(0.8,1.01,0.03),{hand="detail",pile=rim_gold,coverage=3,fill=true,tool={kind="round",width=1.3,point=0.6},angle=ang,clip=F})
-- vault apertures and seams
local phi=0.6180339887
local wb=brush{kind="round",width=1.2,stiffness=0.5}
local k=0
for _,s in ipairs({-8,-3.5,1,5.5}) do
  local t=104+rand(0,2)
  while t<238 do
    k=k+1
    local q=spt(s,t)
    if F:shrink(1.8):at(q[1],q[2])>0.5 and rand()<0.8 then
      local lit=rand()<0.2
      wb:reload(lit and win_warm or win_dead,0.6); wb:touch(q[1],q[2],{pressure=rand(0.45,0.65)})
    end
    t=t+3.3*(0.8+0.5*((k*phi)%1))
  end
end
local sb=brush{kind="round",width=0.9,point=0.4,stiffness=0.5}
local nx,ny=-SV[2],SV[1]
for _,t in ipairs({118,131,152,171,189,201,214,229}) do
  local c=spt(0,t)
  sb:reload(pl_m,0.5)
  sb:stroke({{c[1]-nx*15,c[2]-ny*15},{c[1]+nx*15,c[2]+ny*15}},{pressure={0.45,0.4},clip=F:shrink(1)})
end
