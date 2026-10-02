-- easel session "wanderer": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=790, aspect=0.79, linen={18,16}, seed=1818, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"raw sienna",3},{"Mars brown",2},{"lead white",3},{"ultramarine blue",0.5}}, um=30, apply="brush"}}} print(W,H)

--@ chunk 2
G = {R=100, h=1.5, Zc=4, pitch=0.15, F=906, cx=500, cy=0}
function G.proj(X,Y,Z)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Yc=Y-G.h
  local Yp=Yc*c+Z*s; local Zp=-Yc*s+Z*c
  return G.cx+G.F*X/Zp, G.cy-G.F*Yp/Zp, Zp
end
local _,ay=G.proj(0,0,G.Zc); G.cy = 860-ay
function G.dome(r,th)  -- geodesic r metres from apex, azimuth th (0 = away from camera)
  local phi=r/G.R
  local X=G.R*math.sin(phi)*math.sin(th)
  local Y=-G.R+G.R*math.cos(phi)
  local Z=G.Zc+G.R*math.sin(phi)*math.cos(th)
  return X,Y,Z
end
function G.dp(r,th) return G.proj(G.dome(r,th)) end
-- limb envelope
G.limb={}
for xi=0,100 do G.limb[xi]=1e9 end
for ti=0,720 do local th=ti/720*2*math.pi
  for ri=1,600 do local r=ri*0.1
    local x,y,z=G.dp(r,th)
    if z>0.3 then local xi=math.floor(x/10+0.5) if xi>=0 and xi<=100 and y<G.limb[xi] then G.limb[xi]=y end end
  end end
function G.limbY(x) local xi=clamp(x/10,0,100); local a=math.floor(xi); local b=math.min(a+1,100); return lerp(G.limb[a],G.limb[b],xi-a) end
SUN={x=540,y=560,r=320}
local c=chalk()
local pts={}
for i=0,64 do local a=i/64*2*math.pi pts[#pts+1]={SUN.x+SUN.r*math.cos(a), SUN.y+SUN.r*math.sin(a)} end
c:sketch(pts,{pressure=0.25, passes=2})
local lp={} for xi=0,100 do lp[#lp+1]={xi*10, G.limb[xi]} end
c:line(lp,{pressure=0.35})
-- figure gesture
c:sketch({{442,342},{470,338},{496,350},{500,385},{485,402},{452,402},{438,380},{442,342}},{pressure=0.3})
c:sketch({{392,440},{410,410},{470,400},{530,410},{550,440},{545,470},{532,560},{512,600},{430,600},{408,560},{395,470},{392,440}},{pressure=0.3})
c:sketch({{445,605},{438,730},{432,845},{420,862},{455,862}},{pressure=0.3})
c:sketch({{500,605},{522,715},{530,820},{548,838}},{pressure=0.3})
c:sketch({{405,440},{392,520},{396,620}},{pressure=0.3})
c:sketch({{537,440},{560,515},{576,585}},{pressure=0.3})
c:line({{580,555},{612,848}},{pressure=0.4})

--@ chunk 3
SUN={x=610,y=640,r=380}
sky_above = below(function(x) return G.limbY(x)+25 end)  -- region above limb (+ margin)
local d0 = ellipse(SUN.x,SUN.y,SUN.r*0.78,SUN.r*0.78)
local d1 = ellipse(SUN.x,SUN.y,SUN.r*0.94,SUN.r*0.94)
local d2 = ellipse(SUN.x,SUN.y,SUN.r,SUN.r)
local pc = pile{{"lead white",4},{"lemon chrome",0.25}}
local pm = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
local pe = pile{{"cadmium yellow",2},{"Indian yellow",0.6},{"lead white",1.2}}
work(d0*sky_above, {hand="body", pile=pc, coverage=3.5, fill=true, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 14"})
work((d1-d0)*sky_above, {hand="body", pile=pm, coverage=3.5, fill=true, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 12", edge="soft"})
work((d2-d1)*sky_above, {hand="body", pile=pe, coverage=3.5, fill=true, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 8", clip=true})

--@ chunk 4
SUN={x=610,y=640,r=380}
sky_above = above(function(x) return G.limbY(x)+20 end)  -- region above limb (+ margin)
local d0 = ellipse(SUN.x,SUN.y,SUN.r*0.78,SUN.r*0.78)
local d1 = ellipse(SUN.x,SUN.y,SUN.r*0.94,SUN.r*0.94)
local d2 = ellipse(SUN.x,SUN.y,SUN.r,SUN.r)
local pc = pile{{"lead white",4},{"lemon chrome",0.25}}
local pm = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
local pe = pile{{"cadmium yellow",2},{"Indian yellow",0.6},{"lead white",1.2}}
work(d0*sky_above, {hand="body", pile=pc, coverage=3.5, fill=true, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 14"})
work((d1-d0)*sky_above, {hand="body", pile=pm, coverage=3.5, fill=true, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 12", edge="soft"})
work((d2-d1)*sky_above, {hand="body", pile=pe, coverage=3.5, fill=true, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 8", clip=true})

--@ chunk 5
local ring = ellipse(SUN.x,SUN.y,SUN.r*0.985,SUN.r*0.985) - ellipse(SUN.x,SUN.y,SUN.r*0.66,SUN.r*0.66)
blend(ring*sky_above, {angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x) end})
blend(ring*sky_above, {angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end})

--@ chunk 6
print(drying(610,400), drying(610,300), drying(400,560))
local band = ellipse(SUN.x,SUN.y,SUN.r*0.87,SUN.r*0.87) - ellipse(SUN.x,SUN.y,SUN.r*0.70,SUN.r*0.70)
local pmid = pile{{"lead white",4},{"lemon chrome",0.25},{"cadmium yellow",0.25}}
work(band*sky_above, {hand="scumble", pile=pmid, coverage=2, angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end, tool="filbert 10", clip=true})
blend((ellipse(SUN.x,SUN.y,SUN.r*0.9,SUN.r*0.9) - ellipse(SUN.x,SUN.y,SUN.r*0.66,SUN.r*0.66))*sky_above, {angle=function(x,y) return math.atan(y-SUN.y,x-SUN.x) end})

--@ chunk 7
local rad=function(x,y) return math.atan(y-SUN.y,x-SUN.x) end
for _,f in ipairs({0.78,0.87,0.94}) do
  local seam=(ellipse(SUN.x,SUN.y,SUN.r*(f+0.035),SUN.r*(f+0.035))-ellipse(SUN.x,SUN.y,SUN.r*(f-0.035),SUN.r*(f-0.035)))*sky_above
  blend(seam,{angle=rad, tool={kind="badger",width=20}})
  blend(seam,{angle=rad})
end

--@ chunk 8
local function ann(a,b) local m=ellipse(SUN.x,SUN.y,SUN.r*b,SUN.r*b) if a>0 then m=m-ellipse(SUN.x,SUN.y,SUN.r*a,SUN.r*a) end return m end
local tan=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end
disc = ellipse(SUN.x,SUN.y,SUN.r,SUN.r)
skyM = sky_above - disc
local pE = pile{{"bone black",2},{"ultramarine blue",1}}
local pD = pile{{"bone black",1.2},{"ultramarine blue",1},{"magenta",0.25},{"burnt sienna",0.2}}
work(skyM - ann(0,1.8), {hand="broad", pile=pE, coverage=3, fill=true, angle=tan, edge="soft"})
work(skyM*ann(1.42,1.85), {hand="broad", pile=pD, coverage=3, fill=true, angle=tan, edge="lost"})

--@ chunk 9
local function ann(a,b) local m=ellipse(SUN.x,SUN.y,SUN.r*b,SUN.r*b) if a>0 then m=m-ellipse(SUN.x,SUN.y,SUN.r*a,SUN.r*a) end return m end
local tan=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end
local pC = pile{{"burnt sienna",2},{"bone black",1.2},{"rose madder",0.4},{"ultramarine blue",0.3}}
local pB = pile{{"red earth",2},{"burnt sienna",1},{"Mars orange",0.6}}
local pA = pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",1}}
local pE = pile{{"bone black",2},{"ultramarine blue",1}}
work(skyM*ann(1.6,1.85), {hand="body", pile=pE, coverage=2, fill=true, angle=tan, edge="lost", tool="filbert 14"})
work(skyM*ann(1.2,1.48), {hand="body", pile=pC, coverage=3, fill=true, angle=tan, edge="lost", tool="filbert 14"})
work(skyM*ann(1.065,1.24), {hand="body", pile=pB, coverage=3, fill=true, angle=tan, edge="lost", tool="filbert 10"})
work(skyM*ann(1.0,1.085), {hand="body", pile=pA, coverage=3, fill=true, angle=tan, edge="soft", tool="filbert 8", clip=-disc})

--@ chunk 10
local rad=function(x,y) return math.atan(y-SUN.y,x-SUN.x) end
print(drying(300,300), drying(100,100))
blend(skyM, {angle=rad})

--@ chunk 11
local tan=function(x,y) return math.atan(y-SUN.y,x-SUN.x)+math.pi/2 end
blend(skyM*ellipse(SUN.x,SUN.y,SUN.r*1.75,SUN.r*1.75), {angle=tan, pressure={0.2,0.4}})

--@ chunk 12
print(wait(18*60)); print(drying(610,400), drying(610,300), drying(300,300), drying(100,100), drying(610,800))

--@ chunk 13
BT = {
  pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}},
  pile{{"burnt sienna",2},{"bone black",1},{"yellow ochre",1}},
  pile{{"raw sienna",2},{"bone black",0.7},{"burnt sienna",1}},
  pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6},{"bone black",0.15}},
  pile{{"yellow ochre",2},{"Mars orange",0.5},{"lead white",1},{"burnt sienna",0.3}},
  pile{{"lead white",2},{"Mars yellow",1},{"yellow ochre",1},{"cadmium yellow",0.3}},
  pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.2}},
}
-- sun direction in world: through canvas point SUN center
function G.unproj(x,y)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Xp=(x-G.cx)/G.F; local Yp=(G.cy-y)/G.F; local Zp=1
  local Y=Yp*c - Zp*s; local Z=Yp*s + Zp*c
  local l=math.sqrt(Xp*Xp+Y*Y+Z*Z) return Xp/l,Y/l,Z/l
end
SD = {G.unproj(SUN.x, SUN.y)}
local SC = {G.unproj(SUN.x, SUN.y)}
local DISC = math.atan(SUN.r/G.F)
function G.hit(x,y)
  local dx,dy,dz = G.unproj(x,y)
  -- sphere centre (0,-R,Zc), ray from (0,h,0)
  local ox,oy,oz = 0, G.h+G.R, -G.Zc
  local b = ox*dx+oy*dy+oz*dz
  local c = ox*ox+oy*oy+oz*oz - G.R*G.R
  local disc = b*b - c
  if disc < 0 then return nil end
  local t = -b - math.sqrt(disc)
  if t <= 0 then return nil end
  local X,Y,Z = dx*t, G.h+dy*t, dz*t
  local nx,ny,nz = X/G.R, (Y+G.R)/G.R, (Z-G.Zc)/G.R
  local d = -(dx*nx+dy*ny+dz*nz)
  local rx,ry,rz = dx+2*d*nx, dy+2*d*ny, dz+2*d*nz
  local ang = math.acos(clamp(rx*SC[1]+ry*SC[2]+rz*SC[3],-1,1))
  return ang/DISC, t
end
local function zone(lo,hi)
  return mask(function(x,y) local s=G.hit(x,y) if not s then return 0 end return (s>=lo and s<hi) and 1 or 0 end)
end
local cuts = {0,0.5,0.85,1.15,1.5,1.9,2.25,9}
local horiz = function(x,y) return 0.25*math.atan((x-470)/900, 1) end
for k=7,1,-1 do
  local m = zone(cuts[k],cuts[k+1])
  if m:area() > 10 then
    local tid = 8-k
    work(m, {hand=(k>=5) and "broad" or "body", pile=BT[tid], coverage=3, fill=true, angle=horiz, edge="soft", tool=(k>=5) and nil or "filbert 12"})
  end
end

--@ chunk 14
dome = below(function(x) return G.limbY(x) - 2 end)
local up = dome * above(function(x) return 840 + 0.00025*(x-470)^2 end)
blend(up, {angle=math.pi/2})
blend(dome, {angle=function(x,y) return 0.25*math.atan((x-470)/900, 1) end, pressure={0.2,0.4}})

--@ chunk 15
print(wait(24*60)); print(drying(500,700), drying(500,1000), drying(300,300), drying(610,400))

--@ chunk 16
print(wait(36*60)); print(drying(500,700), drying(500,1000), drying(300,300), drying(610,400), drying(100,100))

--@ chunk 17
print(wait(3*24*60)); print(drying(500,700), drying(500,1000), drying(300,300), drying(610,400), drying(100,100))

--@ chunk 18
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local up = above(function(x) return G.limbY(x)+2 end)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local pc = pile{{"lead white",4},{"lemon chrome",0.2}}
local pm = pile{{"lead white",3},{"cadmium yellow",0.5},{"lemon chrome",0.3}}
local pe = pile{{"cadmium yellow",2},{"Indian yellow",0.6},{"lead white",1.2}}
local clipD = E(1)*up
work((E(1)-E(0.88))*up, {hand="body", pile=pe, coverage=3, fill=true, angle=tan, tool="filbert 8", clip=clipD})
work((E(0.9)-E(0.7))*up, {hand="body", pile=pm, coverage=3, fill=true, angle=tan, tool="filbert 12", clip=clipD})
work(E(0.72)*up, {hand="body", pile=pc, coverage=3, fill=true, angle=tan, tool="filbert 16", clip=clipD})
work((E(0.97)-E(0.6))*up, {hand="body", pile=pm, coverage=2.5, angle=rad, tool="filbert 10", load=0.25, length={20,55}, clip=clipD})

--@ chunk 19
local domeC = below(function(x) return G.limbY(x) + 3 end)
local g1 = pile{{"raw sienna",2},{"Indian yellow",1},{"burnt sienna",0.5}, medium=0.7}
local g2 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}, medium=0.6}
local core = ellipse(600, 668, 230, 22)
local horiz = function(x,y) return 0.25*math.atan((x-470)/900, 1) end
work(domeC - core:soften(15), {hand="glaze", pile=g1, angle=horiz, clip=domeC, coverage=1.5})
local low = domeC * below(function(x) return 800 + 0.0002*(x-470)^2 end):soften(60)
work(low, {hand="glaze", pile=g2, angle=horiz, clip=domeC, coverage=1.5})

--@ chunk 20
print(wait(36*60)); print(drying(500,700), drying(500,1000), drying(200,900), drying(610,400), drying(800,300))

--@ chunk 21
print(wait(48*60)); print(drying(500,700), drying(500,1000), drying(200,900), drying(610,400), drying(800,300))

--@ chunk 22
-- sun direction in world: through canvas point SUN center
function G.unproj(x,y)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Xp=(x-G.cx)/G.F; local Yp=(G.cy-y)/G.F; local Zp=1
  local Y=Yp*c - Zp*s; local Z=Yp*s + Zp*c
  local l=math.sqrt(Xp*Xp+Y*Y+Z*Z) return Xp/l,Y/l,Z/l
end
SD = {G.unproj(SUN.x, SUN.y)}
PA,PP,PN=0.14,0.62,2500
local GA = math.pi*(3-math.sqrt(5))
local a, p = PA or 0.15, PP or 0.75
local cam = {0, G.h, 0}
function G.domeN(r,th)
  local X,Y,Z = G.dome(r,th)
  return X/G.R, (Y+G.R)/G.R, (Z-G.Zc)/G.R
end
PL = {}
local rng = noise{seed=77, octaves=1, period=3}
for i=2,(PN or 560) do
  local r = a*i^p * (1 + 0.025*rng(i*1.7, 3))
  local th = i*GA + 0.03*rng(i*2.3, 9)
  local X,Y,Z = G.dome(r,th)
  local nx,ny,nz = G.domeN(r,th)
  local vx,vy,vz = cam[1]-X, cam[2]-Y, cam[3]-Z
  local vl = math.sqrt(vx*vx+vy*vy+vz*vz)
  local facing = (nx*vx+ny*vy+nz*vz)/vl
  local cx,cy,cz = G.proj(X,Y,Z)
  if facing > 0.004 and cz > 0.25 and cx > -350 and cx < 1350 and cy < 1700 then
    local area = 2*math.pi*r*a*p*i^(p-1)
    local s = math.sqrt(area) * (1 + 0.07*rng(i*3.1, 17))
    local L, Wd = 1.4*s, 1.2*s
    -- local frame
    local dr = 0.01
    local X2,Y2,Z2 = G.dome(r+dr,th)
    local erx,ery,erz = X2-X, Y2-Y, Z2-Z
    local el = math.sqrt(erx^2+ery^2+erz^2); erx,ery,erz = erx/el,ery/el,erz/el
    -- lateral = n x er
    local etx,ety,etz = ny*erz-nz*ery, nz*erx-nx*erz, nx*ery-ny*erx
    local pts, rim = {}, {}
    local n = 28
    for k=0,n-1 do
      local s0 = k/n*2*math.pi
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = (cs > 0) and 0.58*L*cs or 0.42*L*cs
      local v = 0.5*Wd*sn*(cs < 0 and (0.75+0.25*(1+cs)) or 1)
      local lift = 0.06*L*(u/L+0.45)
      local PX = X + erx*u + etx*v + nx*lift
      local PY = Y + ery*u + ety*v + ny*lift
      local PZ = Z + erz*u + etz*v + nz*lift
      local x,y = G.proj(PX,PY,PZ)
      pts[#pts+1] = {x,y}
      if cs > 0.05 then rim[#rim+1] = {x,y, cs} end
    end
    local rim2 = {}
    for k=0,16 do
      local s0 = -1.25 + 2.5*k/16
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = 0.58*L*cs; local v = 0.5*Wd*sn
      local lift = 0.06*L*(u/L+0.45)
      local x,y = G.proj(X + erx*u + etx*v + nx*lift, Y + ery*u + ety*v + ny*lift, Z + erz*u + etz*v + nz*lift)
      rim2[#rim2+1] = {x,y}
    end
    PL[#PL+1] = {rim2=rim2, i=i, r=r, th=th, x=cx, y=cy, z=cz, pts=pts, rim=rim, facing=facing, L=L, nx=nx,ny=ny,nz=nz}
  end
end
table.sort(PL, function(A,B) return A.r > B.r end)
print("plates", #PL)
-- per-plate light: diffuse from upper sun, specular from the whole disc
local LD = {G.unproj(SUN.x, SUN.y-230)}
local SC = {G.unproj(SUN.x, SUN.y)}
local DISC = math.atan(SUN.r/G.F)
local jn = noise{seed=31, octaves=1, period=1.3}
for _,P in ipairs(PL) do
  local X,Y,Z = G.dome(P.r,P.th)
  -- plate normal: dome normal tilted toward apex by lift slope, plus handmade wobble
  local X2,Y2,Z2 = G.dome(P.r+0.01,P.th)
  local ex,ey,ez = X2-X,Y2-Y,Z2-Z; local el=math.sqrt(ex*ex+ey*ey+ez*ez); ex,ey,ez=ex/el,ey/el,ez/el
  local tilt = 0.10 + 0.05*jn(P.i*1.1,1)
  local wob1, wob2 = 0.06*jn(P.i*0.7,5), 0.06*jn(P.i*0.9,8)
  local nx = P.nx - ex*tilt + wob1
  local ny = P.ny - ey*tilt
  local nz = P.nz - ez*tilt + wob2
  local nl = math.sqrt(nx*nx+ny*ny+nz*nz); nx,ny,nz=nx/nl,ny/nl,nz/nl
  P.diff = math.max(0, nx*LD[1]+ny*LD[2]+nz*LD[3])
  -- view dir from point to camera
  local vx,vy,vz = -X, G.h-Y, -Z; local vl=math.sqrt(vx*vx+vy*vy+vz*vz); vx,vy,vz=vx/vl,vy/vl,vz/vl
  local d = vx*nx+vy*ny+vz*nz
  local rx,ry,rz = 2*d*nx-vx, 2*d*ny-vy, 2*d*nz-vz
  local ang = math.acos(clamp(rx*SC[1]+ry*SC[2]+rz*SC[3], -1, 1))
  P.spec = ang / DISC   -- <1 reflects the disc
end
VERD = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5},{"burnt sienna",0.3},{"bone black",0.15}}
POLISH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars yellow",0.6}}
function spec_tone(s)
  if s<0.5 then return 7 elseif s<0.85 then return 6 elseif s<1.15 then return 5 elseif s<1.5 then return 4
  elseif s<1.9 then return 3 elseif s<2.25 then return 2 else return 1 end
end
function paint_dabs(list, o)
  o = o or {}
  local nz = noise{seed=404, octaves=1, period=1}
  local n=0
  for _,P in ipairs(list) do
    local minx,maxx,miny,maxy=1e9,-1e9,1e9,-1e9
    for _,q in ipairs(P.pts) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
    local h, w = maxy-miny, maxx-minx
    local inview = maxx>-10 and minx<1010 and miny<1276 and maxy > G.limbY(clamp((minx+maxx)/2,0,1000))+3
    if inview and h > 2.5 and (not o.filter or o.filter(P)) then
      n=n+1
      local t = spec_tone(P.spec)
      local v = nz(P.i*1.37, 2.1)
      if v > 0.35 then t = math.min(7, t+1) elseif v < -0.35 then t = math.max(1, t-1) end
      local pl = BT[t]
      local u = nz(P.i*0.71, 7.7)
      if u > 0.62 and t <= 4 then pl = VERD elseif u < -0.7 and t >= 3 then pl = POLISH end
      local away = math.cos(P.th) > -0.15
      local cy = P.y + (away and 0.12 or -0.12)*h
      local lim = G.limbY(clamp(P.x,0,1000)) + 2
      cy = math.max(cy, lim + h*0.2)
      local b = brush{kind="filbert", width=clamp(h*0.5, 1.2, 34)}
      b:load(pl, 0.55)
      local half = w*0.28
      b:stroke({{P.x-half, cy+h*0.03},{P.x, cy-h*0.02},{P.x+half, cy+h*0.03}}, {pressure={0.55,0.45}})
    end
  end
  return n
end
print(paint_dabs(PL))

--@ chunk 23
local d = below(function(x) return G.limbY(x) + 1 end)
blend(d, {angle=function(x,y) return 0.25*math.atan((x-470)/900, 1) end})
blend(d, {angle=function(x,y) return 0.25*math.atan((x-470)/900, 1)+0.5 end, pressure={0.25,0.45}})

--@ chunk 24
print(wait(60*60)); print(drying(500,700), drying(500,1000), drying(200,900), drying(800,1200))

--@ chunk 25
local domeC = below(function(x) return G.limbY(x) + 2 end)
local horiz = function(x,y) return 0.25*math.atan((x-470)/900, 1) end
local gbs = pile{{"burnt sienna",2},{"raw sienna",1},{"rose madder",0.2}, medium=0.75}
local gdk = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}, medium=0.55}
local core = ellipse(600, 672, 260, 30):soften(20)
work(domeC - core, {hand="glaze", pile=gbs, angle=horiz, clip=domeC, coverage=1.3})
local low = domeC * below(function(x) return 850 + 0.00035*(x-470)^2 end):soften(80)
work(low, {hand="glaze", pile=gdk, angle=horiz, clip=domeC, coverage=1.6})
local lower = domeC * below(function(x) return 1000 + 0.0003*(x-470)^2 end):soften(80)
work(lower, {hand="glaze", pile=gdk, angle=horiz, clip=domeC, coverage=1.6})

--@ chunk 26
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local glow = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.4}, medium=0.3}
work((E(1.16)-E(0.985))*skyOnly, {hand="scumble", pile=glow, coverage=1.6, angle=tan, tool="filbert 10", load=0.35, clip=skyOnly})
-- streamers
local st = pile{{"lead white",3},{"cadmium yellow",0.5},{"Mars orange",0.15}, medium=0.25}
local b = brush{kind="round", width=7, point=0.8}
local count=0
for k=1,70 do
  local a = rand(-math.pi, 0.05)          -- upper half and the sides
  -- favour two helmet-streamer directions
  if rand(0,1) < 0.5 then a = (rand(0,1)<0.5 and -2.55 or -0.55) + randn(0,0.18) end
  local L = r*rand(0.15, 0.6)
  local x0,y0 = cx + r*0.99*math.cos(a), cy + r*0.99*math.sin(a)
  local bend = randn(0, 0.05)
  local pts = {}
  for t=0,6 do local f=t/6; local aa=a+bend*f; local rr=r*0.99 + L*f pts[#pts+1]={cx+rr*math.cos(aa), cy+rr*math.sin(aa)} end
  if y0 < G.limbY(clamp(x0,0,1000)) - 3 then
    b:reload(st, rand(0.25,0.45))
    b:stroke(pts, {pressure={rand(0.35,0.6), 0.0}, ramps={0.02, 0.6}})
    count=count+1
  end
end
print(count)

--@ chunk 27
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end)
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
blend((E(1.45)-E(1.0))*skyOnly, {angle=rad})
blend((E(1.45)-E(1.0))*skyOnly, {angle=rad, tool={kind="badger", width=24}})
blend((E(1.35)-E(1.03))*skyOnly, {angle=tan, pressure={0.2,0.35}})

--@ chunk 28
print(wait(48*60)); print(drying(250,300), drying(610,200), drying(500,700), drying(500,1000))

--@ chunk 29
print(wait(48*60)); print(drying(250,300), drying(610,200), drying(500,700), drying(500,1000))

--@ chunk 30
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end) - E(1.0)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local Z = {
 {1.40,1.68, pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine blue",0.6},{"rose madder",0.2}}, "filbert 16"},
 {1.24,1.43, pile{{"red earth",1},{"burnt sienna",1},{"bone black",0.8}}, "filbert 14"},
 {1.12,1.26, pile{{"Mars orange",1},{"red earth",1.5},{"burnt sienna",0.5}}, "filbert 12"},
 {1.04,1.14, pile{{"cadmium yellow",1},{"Mars orange",1.2},{"lead white",0.4}}, "filbert 10"},
 {1.0,1.055, pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}, "filbert 8"},
}
for _,z in ipairs(Z) do
  work((E(z[2])-E(z[1]))*skyOnly, {hand="body", pile=z[3], coverage=3, fill=true, angle=tan, tool=z[4], clip=skyOnly})
end

--@ chunk 31
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end) - E(1.0)
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
blend((E(1.75)-E(1.0))*skyOnly, {angle=rad})
blend((E(1.7)-E(1.0))*skyOnly, {angle=tan, pressure={0.2,0.4}})

--@ chunk 32
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end) - E(1.0)
local rad=function(x,y) return math.atan(y-cy,x-cx) end
blend((E(1.86)-E(1.58))*skyOnly, {angle=rad, tool={kind="badger", width=26}, pressure={0.3,0.5}})

--@ chunk 33
print(wait(30*60)); print(drying(500,700), drying(500,1000), drying(200,1200), drying(800,900))

--@ chunk 34
-- sun direction in world: through canvas point SUN center
function G.unproj(x,y)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Xp=(x-G.cx)/G.F; local Yp=(G.cy-y)/G.F; local Zp=1
  local Y=Yp*c - Zp*s; local Z=Yp*s + Zp*c
  local l=math.sqrt(Xp*Xp+Y*Y+Z*Z) return Xp/l,Y/l,Z/l
end
SD = {G.unproj(SUN.x, SUN.y)}
PA,PP,PN=0.14,0.62,2500
local GA = math.pi*(3-math.sqrt(5))
local a, p = PA or 0.15, PP or 0.75
local cam = {0, G.h, 0}
function G.domeN(r,th)
  local X,Y,Z = G.dome(r,th)
  return X/G.R, (Y+G.R)/G.R, (Z-G.Zc)/G.R
end
PL = {}
local rng = noise{seed=77, octaves=1, period=3}
for i=2,(PN or 560) do
  local r = a*i^p * (1 + 0.025*rng(i*1.7, 3))
  local th = i*GA + 0.03*rng(i*2.3, 9)
  local X,Y,Z = G.dome(r,th)
  local nx,ny,nz = G.domeN(r,th)
  local vx,vy,vz = cam[1]-X, cam[2]-Y, cam[3]-Z
  local vl = math.sqrt(vx*vx+vy*vy+vz*vz)
  local facing = (nx*vx+ny*vy+nz*vz)/vl
  local cx,cy,cz = G.proj(X,Y,Z)
  if facing > 0.004 and cz > 0.25 and cx > -350 and cx < 1350 and cy < 1700 then
    local area = 2*math.pi*r*a*p*i^(p-1)
    local s = math.sqrt(area) * (1 + 0.07*rng(i*3.1, 17))
    local L, Wd = 1.4*s, 1.2*s
    -- local frame
    local dr = 0.01
    local X2,Y2,Z2 = G.dome(r+dr,th)
    local erx,ery,erz = X2-X, Y2-Y, Z2-Z
    local el = math.sqrt(erx^2+ery^2+erz^2); erx,ery,erz = erx/el,ery/el,erz/el
    -- lateral = n x er
    local etx,ety,etz = ny*erz-nz*ery, nz*erx-nx*erz, nx*ery-ny*erx
    local pts, rim = {}, {}
    local n = 28
    for k=0,n-1 do
      local s0 = k/n*2*math.pi
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = (cs > 0) and 0.58*L*cs or 0.42*L*cs
      local v = 0.5*Wd*sn*(cs < 0 and (0.75+0.25*(1+cs)) or 1)
      local lift = 0.06*L*(u/L+0.45)
      local PX = X + erx*u + etx*v + nx*lift
      local PY = Y + ery*u + ety*v + ny*lift
      local PZ = Z + erz*u + etz*v + nz*lift
      local x,y = G.proj(PX,PY,PZ)
      pts[#pts+1] = {x,y}
      if cs > 0.05 then rim[#rim+1] = {x,y, cs} end
    end
    local rim2 = {}
    for k=0,16 do
      local s0 = -1.25 + 2.5*k/16
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = 0.58*L*cs; local v = 0.5*Wd*sn
      local lift = 0.06*L*(u/L+0.45)
      local x,y = G.proj(X + erx*u + etx*v + nx*lift, Y + ery*u + ety*v + ny*lift, Z + erz*u + etz*v + nz*lift)
      rim2[#rim2+1] = {x,y}
    end
    PL[#PL+1] = {rim2=rim2, i=i, r=r, th=th, x=cx, y=cy, z=cz, pts=pts, rim=rim, facing=facing, L=L, nx=nx,ny=ny,nz=nz}
  end
end
table.sort(PL, function(A,B) return A.r > B.r end)
print("plates", #PL)
-- per-plate light: diffuse from upper sun, specular from the whole disc
local LD = {G.unproj(SUN.x, SUN.y-230)}
local SC = {G.unproj(SUN.x, SUN.y)}
local DISC = math.atan(SUN.r/G.F)
local jn = noise{seed=31, octaves=1, period=1.3}
for _,P in ipairs(PL) do
  local X,Y,Z = G.dome(P.r,P.th)
  -- plate normal: dome normal tilted toward apex by lift slope, plus handmade wobble
  local X2,Y2,Z2 = G.dome(P.r+0.01,P.th)
  local ex,ey,ez = X2-X,Y2-Y,Z2-Z; local el=math.sqrt(ex*ex+ey*ey+ez*ez); ex,ey,ez=ex/el,ey/el,ez/el
  local tilt = 0.10 + 0.05*jn(P.i*1.1,1)
  local wob1, wob2 = 0.06*jn(P.i*0.7,5), 0.06*jn(P.i*0.9,8)
  local nx = P.nx - ex*tilt + wob1
  local ny = P.ny - ey*tilt
  local nz = P.nz - ez*tilt + wob2
  local nl = math.sqrt(nx*nx+ny*ny+nz*nz); nx,ny,nz=nx/nl,ny/nl,nz/nl
  P.diff = math.max(0, nx*LD[1]+ny*LD[2]+nz*LD[3])
  -- view dir from point to camera
  local vx,vy,vz = -X, G.h-Y, -Z; local vl=math.sqrt(vx*vx+vy*vy+vz*vz); vx,vy,vz=vx/vl,vy/vl,vz/vl
  local d = vx*nx+vy*ny+vz*nz
  local rx,ry,rz = 2*d*nx-vx, 2*d*ny-vy, 2*d*nz-vz
  local ang = math.acos(clamp(rx*SC[1]+ry*SC[2]+rz*SC[3], -1, 1))
  P.spec = ang / DISC   -- <1 reflects the disc
end
LIPS = {
  pile{{"lead white",4},{"lemon chrome",0.4}},
  pile{{"lead white",3},{"cadmium yellow",0.8},{"yellow ochre",0.5}},
  pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",1.2}},
}
DARKS = {
  pile{{"raw sienna",2},{"bone black",0.7},{"burnt sienna",1}},
  pile{{"burnt sienna",2},{"bone black",1},{"bone brown",1}},
  pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.6}},
}
function paint_rims(list, o)
  o = o or {}
  local lip = brush{kind="round", width=3, point=0.7}
  local dk = brush{kind="round", width=8, point=0.3}
  local n=0
  for _,P in ipairs(list) do
    local minx,maxx,miny,maxy=1e9,-1e9,1e9,-1e9
    for _,q in ipairs(P.pts) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
    local h = maxy-miny
    local inview = maxx>-10 and minx<1010 and miny<1276 and maxy > G.limbY(clamp((minx+maxx)/2,0,1000))+1
    if inview and (not o.filter or o.filter(P)) then
      n=n+1
      local s = P.spec
      local li = (s<1.0) and 1 or (s<1.6 and 2 or 3)
      local di = (s<1.0) and 1 or (s<1.7 and 2 or 3)
      local away = math.cos(P.th) > -0.15
      -- keep the rim inside the dome
      local rim = {}
      for _,q in ipairs(P.rim2) do rim[#rim+1] = {q[1], math.max(q[2], G.limbY(clamp(q[1],0,1000))+1)} end
      local bw = clamp(h*(away and 0.10 or 0.16), 0.8, 16)
      if bw > 1.2 then
        local sh = {} for _,q in ipairs(rim) do sh[#sh+1] = {q[1], q[2] + bw*0.55} end
        dk:reload(DARKS[di], 0.7)
        dk:stroke(sh, {pressure={dk:pressure_for(bw), dk:pressure_for(bw)}, swell={0.4,1,1,0.4}})
      end
      local lw = clamp(h*0.045, 0.5, 3.2)
      lip:reload(LIPS[li], 0.65)
      lip:stroke(rim, {pressure={lip:pressure_for(lw)*0.6, lip:pressure_for(lw)*0.6}, swell={0.2,1,1,0.3}})
    end
  end
  return n
end
print(paint_rims(PL))

--@ chunk 35
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
local cp = pile{{"bone black",1},{"rose madder",1},{"burnt sienna",1},{"ultramarine blue",0.3}}
work(M.body + M.rifle, {hand="body", pile=dk, coverage=3, fill=true, clip=true, tool="filbert 6", angle=math.pi/2})
work(M.cape + M.hood, {hand="body", pile=cp, coverage=3, fill=true, clip=true, tool="filbert 8", angle=math.pi/2})

--@ chunk 36
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local bounce = pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone black",0.35},{"lead white",0.15}}
local b = brush{kind="filbert", width=9}
-- leg backs: a warm bounce down the middle of each segment, stronger low
local function legband(pts, ws, k, load)
  for i=1,#pts-1 do
    local p,q = pts[i], pts[i+1]
    b:reload(bounce, load)
    b:stroke({{p[1]+k, p[2]+6},{q[1]+k, q[2]-4}}, {pressure={0.45,0.6}, clip=M.legs})
  end
end
legband(FIG.lthigh, FIG.lthighW, 2, 0.35)
legband(FIG.lshin, FIG.lshinW, 1, 0.5)
legband(FIG.rthigh, FIG.rthighW, -2, 0.35)
legband(FIG.rshin, FIG.rshinW, -1, 0.5)
-- cape folds: ridges and valleys falling from the shoulders
local ridge = pile{{"rose madder",1},{"burnt sienna",1},{"vermilion",0.3},{"lead white",0.15},{"bone black",0.2}}
local valley = pile{{"bone black",1.2},{"rose madder",0.6},{"ultramarine blue",0.3}}
local fb = brush{kind="filbert", width=7}
local folds = {
  {{404,430},{398,480},{396,540},{398,556}, "v"},
  {{418,418},{414,470},{412,520},{413,558}, "r"},
  {{437,425},{434,480},{432,548}, "v"},
  {{455,430},{455,490},{452,545}, "r"},
  {{478,428},{480,490},{480,538}, "v"},
  {{499,425},{502,480},{503,538}, "r"},
  {{520,422},{526,470},{527,532}, "v"},
  {{538,432},{544,480},{543,525}, "r"},
}
for _,f in ipairs(folds) do
  local pts = {} for i=1,#f-1 do pts[#pts+1]=f[i] end
  fb:reload(f[#f]=="r" and ridge or valley, 0.45)
  fb:stroke(pts, {pressure={0.35,0.6}, clip=M.cape})
end

--@ chunk 37
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
blend(M.legs, {angle=math.pi/2, tool={kind="badger", width=14}})
blend(M.legs, {angle=0, tool={kind="badger", width=10}, pressure={0.2,0.4}})
blend(M.cape, {angle=0, tool={kind="badger", width=16}, pressure={0.25,0.45}})

--@ chunk 38
print(wait(48*60)); print(drying(466,370), drying(470,470), drying(441,760), drying(600,700))

--@ chunk 39
print(wait(48*60)); print(drying(466,370), drying(470,470), drying(441,760), drying(600,700), drying(300,300))

--@ chunk 40
print(wait(72*60)); print(drying(466,370), drying(470,470), drying(441,760), drying(600,700), drying(300,300))

--@ chunk 41
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local glow = pile{{"lead white",3},{"cadmium yellow",0.35},{"lemon chrome",0.2}}
local b = brush{kind="filbert", width=5}
local function rimline(pts, load, pr)
  b:reload(glow, load or 0.4)
  b:stroke(pts, {pressure={pr or 0.3, pr or 0.3}, swell={0.3,1,1,1,0.3}})
end
local H = FIG.head
rimline({H[11],H[12],H[13],H[14],H[1],H[2],H[3],H[4],H[5],H[6]}, 0.45, 0.32)
local C = FIG.cape
rimline({C[1],C[2],C[3],C[4],C[5],C[6]}, 0.4, 0.3)
rimline({C[25],C[24],C[23],C[22],C[21],C[20]}, 0.4, 0.3)
rimline({{378,515},{377,560},{380,605}}, 0.35, 0.25)
rimline({{557,500},{570,540},{588,572}}, 0.35, 0.25)
rimline({{587,546},{591,600},{596,652}}, 0.3, 0.2)

--@ chunk 42
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
local M = fig_masks()
local r2 = brush{kind="round", width=2.5, point=0.6}
local r4 = brush{kind="round", width=4.5, point=0.5}
local f4 = brush{kind="filbert", width=5}
-- helmet: lit crescent on the top, ridge, seam, vent
line(f4, FP.lit, {{441,355},{452,343},{466,339},{481,341},{492,351}}, 0.6, 0.45, {clip=M.head, swell={0.4,1,1,1,0.4}})
line(r4, FP.mid, {{445,360},{456,350},{467,347},{480,349},{489,358}}, 0.45, 0.4, {clip=M.head})
line(r2, FP.mid, {{467,342},{468,360},{468,378},{468,396}}, 0.5, 0.35, {clip=M.head})
line(r2, FP.lit, {{467,341},{467,352}}, 0.5, 0.35, {clip=M.head})
line(r2, FP.seam, {{437,381},{452,385},{468,386},{484,385},{498,381}}, 0.6, 0.45, {clip=M.head})
line(r2, FP.mid, {{439,386},{453,390},{468,391},{483,390},{496,386}}, 0.4, 0.3, {clip=M.head})
line(r4, FP.mid, {{462,395},{474,395}}, 0.5, 0.5, {clip=M.head})
-- hood: lit roll
line(r4, FP.crim, {{430,407},{446,398},{468,401},{490,398},{506,407}}, 0.5, 0.4, {clip=M.hood})
line(r2, FP.crimdk, {{432,415},{450,417},{468,418},{488,417},{504,414}}, 0.5, 0.4, {clip=M.hood})
-- cape: warm shoulder planes, worn cross, hem lit by the hull below
line(f4, FP.crim, {{398,428},{410,416},{428,408}}, 0.45, 0.4, {clip=M.cape})
line(f4, FP.crim, {{508,408},{526,414},{540,426}}, 0.45, 0.4, {clip=M.cape})
local fc = brush{kind="filbert", width=7}
line(fc, FP.bone, {{468,432},{468,470},{469,512}}, 0.22, 0.45, {clip=M.cape})
line(fc, FP.bone, {{443,458},{468,457},{494,456}}, 0.22, 0.45, {clip=M.cape})
local C = FIG.cape
local hem = {} for i=7,19 do hem[#hem+1] = {C[i][1], C[i][2]-2} end
line(r2, FP.warm, hem, 0.5, 0.35, {clip=M.cape})

--@ chunk 43
local domeC = below(function(x) return G.limbY(x) + 2 end)
local horiz = function(x,y) return 0.25*math.atan((x-470)/900, 1) end
local gdk = pile{{"bone brown",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}, medium=0.55}
-- the near hull, darker toward us and toward the sides
local low = domeC * below(function(x) return 930 + 0.0004*(x-470)^2 end):soften(90)
work(low, {hand="glaze", pile=gdk, angle=horiz, clip=domeC, coverage=1.8})
local sides = domeC * (below(function(x) return 760 end)) * mask(function(x,y) local d=math.abs(x-480) return d>300 and 1 or 0 end):soften(120)
work(sides, {hand="glaze", pile=gdk, angle=horiz, clip=domeC, coverage=1.2})
-- his shadow, cast toward us by the sun behind him: soft-edged wedge
local sh = poly({{430,858},{545,830},{560,860},{700,1266},{250,1266}}, true):soften(40)
local gsh = pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.4}, medium=0.5}
work(sh, {hand="glaze", pile=gsh, angle=math.pi/2, clip=domeC, coverage=1.6})

--@ chunk 44
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local domeC = below(function(x) return G.limbY(x) + 3 end) - M.all:grow(2)
local horiz = function(x,y) return 0.25*math.atan((x-470)/900, 1) end
blend(domeC, {angle=horiz})
blend(domeC * below(function(x) return 760 end), {angle=function(x,y) return horiz(x,y)+0.6 end, tool={kind="badger", width=60}, pressure={0.3,0.5}})

--@ chunk 45
print(drying(100,100), drying(150,400), drying(900,150), drying(300,250), drying(60,600))

--@ chunk 46
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end) - E(1.0)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local deep = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.15}}
local warmdk = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine blue",0.6},{"rose madder",0.15}}
work(skyOnly - E(1.85), {hand="broad", pile=deep, coverage=3, fill=true, angle=tan, edge="lost"})
work(skyOnly * (E(1.9) - E(1.6)), {hand="body", pile=warmdk, coverage=2.5, fill=true, angle=tan, edge="lost", tool="filbert 14"})
blend(skyOnly * (E(2.0) - E(1.5)), {angle=rad, tool={kind="badger", width=30}})
blend(skyOnly - E(1.55), {angle=tan, pressure={0.2,0.4}})

--@ chunk 47
print(wait(72*60)); print(drying(100,100), drying(470,470), drying(441,760), drying(600,700), drying(500,1000), drying(466,370))

--@ chunk 48
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local gc = pile{{"rose madder",1},{"bone black",0.8},{"burnt sienna",0.6}, medium=0.6}
work(M.cape, {hand="glaze", pile=gc, clip=M.cape, angle=math.pi/2, coverage=1.5, tool={kind="filbert", width=14, stiffness=0.2}})
local gh = pile{{"bone black",1},{"ultramarine blue",0.4},{"burnt sienna",0.4}, medium=0.6}
local lowerhead = M.head * below(function(x) return 356 end)
work(lowerhead, {hand="glaze", pile=gh, clip=lowerhead, angle=0, coverage=1.5, tool={kind="filbert", width=10, stiffness=0.2}})

--@ chunk 49
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
local M = fig_masks()
local crossM = (ribbon({{468,430},{469,514}}, 12) + ribbon({{440,458},{496,456}}, 12)) * M.cape
local cdk = pile{{"rose madder",1},{"bone black",0.9},{"burnt sienna",0.6},{"lead white",0.1}, medium=0.25}
work(crossM, {hand="scumble", pile=cdk, coverage=1.4, clip=M.cape, load=0.35, tool="filbert 5"})

--@ chunk 50
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
function limb_edge(pts, ws, side, inset)
  local out = {}
  for i=1,#pts do
    local a = pts[math.max(1,i-1)]; local b = pts[math.min(#pts,i+1)]
    local tx,ty = b[1]-a[1], b[2]-a[2]; local l = math.sqrt(tx*tx+ty*ty); tx,ty = tx/l,ty/l
    local nx,ny = -ty, tx           -- for a downward limb this points to the left
    local d = (ws[i]/2 - inset) * (side < 0 and 1 or -1)
    out[#out+1] = {pts[i][1] + nx*d, pts[i][2] + ny*d}
  end
  return out
end
local M = fig_masks()
local r15 = brush{kind="round", width=2, point=0.7}
local r3 = brush{kind="round", width=3.5, point=0.5}
local f6 = brush{kind="filbert", width=7}
local legs = {{FIG.lthigh,FIG.lthighW},{FIG.lshin,FIG.lshinW},{FIG.rthigh,FIG.rthighW},{FIG.rshin,FIG.rshinW}}
-- warm bounce on the backs of the calves and thighs, soft and low
for k,L in ipairs(legs) do
  local c = limb_edge(L[1], L[2], -1, L[2][1]*0.5)  -- centre line
  f6:reload(FP.warm, (k%2==0) and 0.3 or 0.2)
  f6:stroke(c, {pressure={0.35,0.5}, clip=M.legs})
end
-- rim lights down both sides of every leg segment
for _,L in ipairs(legs) do
  line(r15, FP.lit, limb_edge(L[1], L[2], -1, 1.6), 0.55, 0.35, {clip=M.legs, swell={0.5,1,1,0.6}})
  line(r15, FP.lit, limb_edge(L[1], L[2], 1, 1.6), 0.5, 0.3, {clip=M.legs, swell={0.5,1,1,0.6}})
end
-- knees: dark joint gap, then the lit lip of the shin housing
line(r3, FP.seam, {{425,731},{441,736},{457,731}}, 0.6, 0.6, {clip=M.legs})
line(r15, FP.mid, {{427,741},{441,746},{455,741}}, 0.5, 0.4, {clip=M.legs})
line(r3, FP.seam, {{499,709},{514,714},{529,707}}, 0.6, 0.6, {clip=M.legs})
line(r15, FP.mid, {{501,718},{515,723},{528,716}}, 0.5, 0.4, {clip=M.legs})
-- thigh plate lower edges catching the hull's light
line(r15, FP.warm, {{428,700},{442,704},{458,699}}, 0.5, 0.4, {clip=M.legs})
line(r15, FP.warm, {{495,684},{508,688},{522,682}}, 0.5, 0.4, {clip=M.legs})
-- calf pistons on the outer backs
line(r3, FP.mid, {{429,752},{430,790},{432,826}}, 0.5, 0.45, {clip=M.legs})
line(r15, FP.lit, {{428,754},{429,790},{431,824}}, 0.45, 0.28, {clip=M.legs})
line(r3, FP.mid, {{529,724},{530,762},{531,798}}, 0.5, 0.45, {clip=M.legs})
line(r15, FP.lit, {{531,726},{532,762},{532,796}}, 0.45, 0.28, {clip=M.legs})
-- heels: lit lower edges
line(r15, FP.warm, {{421,855},{437,857},{455,855}}, 0.5, 0.4, {clip=M.legs})
line(r15, FP.warm, {{508,824},{522,826},{537,824}}, 0.5, 0.4, {clip=M.legs})

--@ chunk 51
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
blend(M.legs, {angle=0, tool={kind="badger", width=10}, pressure={0.3,0.5}})
blend(M.legs, {angle=math.pi/2, tool={kind="badger", width=8}, pressure={0.2,0.4}})

--@ chunk 52
print(wait(48*60)); print(drying(441,760), drying(514,750), drying(470,470))

--@ chunk 53
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
local M = fig_masks()
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
work(M.legs, {hand="body", pile=dk, coverage=3.5, fill=true, clip=true, tool="filbert 5", angle=math.pi/2})
local f8 = brush{kind="filbert", width=10}
local warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.4}}
local strokes = {
  {{439,770},{438,800},{437,832}},
  {{519,750},{521,778},{522,800}},
  {{442,690},{441,725}},
  {{510,680},{513,705}},
}
for _,s in ipairs(strokes) do f8:reload(warm, 0.3); f8:stroke(s, {pressure={0.4,0.55}, clip=M.legs}) end

--@ chunk 54
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
blend(M.legs, {angle=math.pi/2, tool={kind="badger", width=12}, pressure={0.25,0.45}})

--@ chunk 55
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
local knees = ellipse(441,736,19,13) + ellipse(514,713,18,12) + ellipse(437,832,15,9) + ellipse(522,804,14,8)
local hips = ellipse(447,618,24,14) + ellipse(494,617,23,14)
work(knees + hips, {hand="detail", pile=dk, coverage=3, fill=true, clip=true})
-- antenna mast from the back, a thin dark line against the Sun
local b = brush{kind="round", width=2.2, point=0.5}
b:load(dk, 0.8)
b:stroke({{424,418},{420,380},{417,340},{415,312}}, {pressure={0.6,0.45}})
b:load(dk, 0.8)
b:touch(415,311,{pressure=0.5})

--@ chunk 56
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
local parts = poly({{578,536},{589,535},{590,550},{577,551}}) -- muzzle brake
  + poly({{600,712},{611,710},{625,742},{614,748}}, true)        -- magazine
  + poly({{596,690},{607,689},{609,720},{597,722}})              -- receiver
  + poly({{601,828},{617,826},{620,856},{600,858}}, true)        -- butt plate
work(parts, {hand="detail", pile=dk, coverage=3, fill=true, clip=true})
local b = brush{kind="round", width=2, point=0.4}
b:load(dk, 0.8)
b:stroke({{588,612},{582,660},{581,705},{588,750},{603,790}}, {pressure={0.55,0.55}})
-- fingers of the hanging left hand and its thumb
local f = brush{kind="round", width=5, point=0.7}
for _,s in ipairs({{{386,640},{385,652},{388,660}}, {{393,645},{393,658},{396,665}}, {{400,643},{402,655},{405,660}}}) do
  f:load(dk, 0.7); f:stroke(s, {pressure={0.7,0.25}})
end

--@ chunk 57
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1.5)
local lim = function(x) return G.limbY(x) end
local band1 = (below(function(x) return lim(x)+1 end) * above(function(x) return lim(x) + 55 - 0.00008*(x-610)^2 end)) * ellipse(610, 680, 360, 90):soften(60)
local band2 = (below(function(x) return lim(x)+1 end) * above(function(x) return lim(x) + 22 end)) * ellipse(610, 668, 260, 40):soften(40)
local g1 = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars yellow",0.4}, medium=0.15}
local g2 = pile{{"lead white",4},{"lemon chrome",0.3},{"cadmium yellow",0.2}}
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
work(band1 - fg, {hand="scumble", pile=g1, coverage=1.3, angle=horiz, clip=below(function(x) return lim(x)+1 end) - fg, load=0.4, tool="filbert 8"})
work(band2 - fg, {hand="scumble", pile=g2, coverage=1.5, angle=horiz, clip=below(function(x) return lim(x)+1 end) - fg, load=0.45, tool="filbert 6"})

--@ chunk 58
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1.5)
local lim = function(x) return G.limbY(x) end
local zone = below(function(x) return lim(x)+1 end) * above(function(x) return lim(x) + 95 end) * rect(170, 600, 800, 200)
blend(zone - fg, {angle=math.pi/2, tool={kind="badger", width=22}})
blend(zone - fg, {angle=0.05, tool={kind="badger", width=30}, pressure={0.2,0.4}})

--@ chunk 59
print(wait(48*60)); print(drying(250,700), drying(610,680), drying(900,690))

--@ chunk 60
print(wait(48*60)); print(drying(250,700), drying(610,680), drying(900,690), drying(441,760))

--@ chunk 61
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1)
local lim = function(x) return G.limbY(x) end
local function strip(a, b) return below(function(x) return lim(x)+a end) * above(function(x) return lim(x)+b end) end
local domeTop = below(function(x) return lim(x)+0.5 end) - fg
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
local S = {
  {70, 118, pile{{"yellow ochre",1.5},{"burnt sienna",1},{"lead white",0.35},{"bone black",0.15}}},
  {36, 74, pile{{"yellow ochre",2},{"Mars orange",0.4},{"lead white",0.8},{"burnt sienna",0.3}}},
  {12, 40, pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.4}}},
  {0, 14, pile{{"lead white",3},{"cadmium yellow",0.5},{"lemon chrome",0.2}}},
}
for _,s in ipairs(S) do
  work(strip(s[1], s[2]) - fg, {hand="body", pile=s[3], coverage=3, fill=true, angle=horiz, clip=domeTop, tool="filbert 10", edge="soft"})
end
blend(strip(0, 125) - fg, {angle=horiz, tool={kind="badger", width=24}})

--@ chunk 62
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1)
local lim = function(x) return G.limbY(x) end
local function strip(a, b) return below(function(x) return lim(x)+a end) * above(function(x) return lim(x)+b end) end
local domeTop = below(function(x) return lim(x)+0.5 end) - fg
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
local bz = pile{{"yellow ochre",1.5},{"burnt sienna",1.2},{"bone black",0.3},{"lead white",0.2}}
local bz2 = pile{{"burnt sienna",1.5},{"bone black",0.6},{"yellow ochre",0.8}}
local left = mask(function(x,y) return x < 230 and 1 or 0 end)
local right = mask(function(x,y) return x > 930 and 1 or 0 end)
local leftm = mask(function(x,y) return (x >= 200 and x < 330) and 1 or 0 end)
local rightm = mask(function(x,y) return (x > 860 and x <= 950) and 1 or 0 end)
work(strip(3,125)*(left+right) - fg, {hand="body", pile=bz2, coverage=3, fill=true, angle=horiz, clip=domeTop, tool="filbert 10", edge="lost"})
work(strip(3,125)*(leftm+rightm) - fg, {hand="body", pile=bz, coverage=2.2, fill=true, angle=horiz, clip=domeTop, tool="filbert 10", edge="lost"})
work(strip(40,125)*mask(function(x,y) return (x>330 and x<860) and 1 or 0 end) - fg, {hand="body", pile=bz, coverage=1.3, angle=horiz, clip=domeTop, tool="filbert 8", edge="lost", load=0.4})
blend(strip(0, 130) - fg, {angle=horiz, tool={kind="badger", width=30}})

--@ chunk 63
print(wait(60*60)); print(drying(250,700), drying(610,680), drying(900,690), drying(441,760))

--@ chunk 64
print(wait(72*60)); print(drying(250,700), drying(610,680), drying(900,690), drying(441,760))

--@ chunk 65
-- sun direction in world: through canvas point SUN center
function G.unproj(x,y)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Xp=(x-G.cx)/G.F; local Yp=(G.cy-y)/G.F; local Zp=1
  local Y=Yp*c - Zp*s; local Z=Yp*s + Zp*c
  local l=math.sqrt(Xp*Xp+Y*Y+Z*Z) return Xp/l,Y/l,Z/l
end
SD = {G.unproj(SUN.x, SUN.y)}
PA,PP,PN=0.14,0.62,2500
local GA = math.pi*(3-math.sqrt(5))
local a, p = PA or 0.15, PP or 0.75
local cam = {0, G.h, 0}
function G.domeN(r,th)
  local X,Y,Z = G.dome(r,th)
  return X/G.R, (Y+G.R)/G.R, (Z-G.Zc)/G.R
end
PL = {}
local rng = noise{seed=77, octaves=1, period=3}
for i=2,(PN or 560) do
  local r = a*i^p * (1 + 0.025*rng(i*1.7, 3))
  local th = i*GA + 0.03*rng(i*2.3, 9)
  local X,Y,Z = G.dome(r,th)
  local nx,ny,nz = G.domeN(r,th)
  local vx,vy,vz = cam[1]-X, cam[2]-Y, cam[3]-Z
  local vl = math.sqrt(vx*vx+vy*vy+vz*vz)
  local facing = (nx*vx+ny*vy+nz*vz)/vl
  local cx,cy,cz = G.proj(X,Y,Z)
  if facing > 0.004 and cz > 0.25 and cx > -350 and cx < 1350 and cy < 1700 then
    local area = 2*math.pi*r*a*p*i^(p-1)
    local s = math.sqrt(area) * (1 + 0.07*rng(i*3.1, 17))
    local L, Wd = 1.4*s, 1.2*s
    -- local frame
    local dr = 0.01
    local X2,Y2,Z2 = G.dome(r+dr,th)
    local erx,ery,erz = X2-X, Y2-Y, Z2-Z
    local el = math.sqrt(erx^2+ery^2+erz^2); erx,ery,erz = erx/el,ery/el,erz/el
    -- lateral = n x er
    local etx,ety,etz = ny*erz-nz*ery, nz*erx-nx*erz, nx*ery-ny*erx
    local pts, rim = {}, {}
    local n = 28
    for k=0,n-1 do
      local s0 = k/n*2*math.pi
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = (cs > 0) and 0.58*L*cs or 0.42*L*cs
      local v = 0.5*Wd*sn*(cs < 0 and (0.75+0.25*(1+cs)) or 1)
      local lift = 0.06*L*(u/L+0.45)
      local PX = X + erx*u + etx*v + nx*lift
      local PY = Y + ery*u + ety*v + ny*lift
      local PZ = Z + erz*u + etz*v + nz*lift
      local x,y = G.proj(PX,PY,PZ)
      pts[#pts+1] = {x,y}
      if cs > 0.05 then rim[#rim+1] = {x,y, cs} end
    end
    local rim2 = {}
    for k=0,16 do
      local s0 = -1.25 + 2.5*k/16
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = 0.58*L*cs; local v = 0.5*Wd*sn
      local lift = 0.06*L*(u/L+0.45)
      local x,y = G.proj(X + erx*u + etx*v + nx*lift, Y + ery*u + ety*v + ny*lift, Z + erz*u + etz*v + nz*lift)
      rim2[#rim2+1] = {x,y}
    end
    PL[#PL+1] = {rim2=rim2, i=i, r=r, th=th, x=cx, y=cy, z=cz, pts=pts, rim=rim, facing=facing, L=L, nx=nx,ny=ny,nz=nz}
  end
end
table.sort(PL, function(A,B) return A.r > B.r end)
print("plates", #PL)
-- per-plate light: diffuse from upper sun, specular from the whole disc
local LD = {G.unproj(SUN.x, SUN.y-230)}
local SC = {G.unproj(SUN.x, SUN.y)}
local DISC = math.atan(SUN.r/G.F)
local jn = noise{seed=31, octaves=1, period=1.3}
for _,P in ipairs(PL) do
  local X,Y,Z = G.dome(P.r,P.th)
  -- plate normal: dome normal tilted toward apex by lift slope, plus handmade wobble
  local X2,Y2,Z2 = G.dome(P.r+0.01,P.th)
  local ex,ey,ez = X2-X,Y2-Y,Z2-Z; local el=math.sqrt(ex*ex+ey*ey+ez*ez); ex,ey,ez=ex/el,ey/el,ez/el
  local tilt = 0.10 + 0.05*jn(P.i*1.1,1)
  local wob1, wob2 = 0.06*jn(P.i*0.7,5), 0.06*jn(P.i*0.9,8)
  local nx = P.nx - ex*tilt + wob1
  local ny = P.ny - ey*tilt
  local nz = P.nz - ez*tilt + wob2
  local nl = math.sqrt(nx*nx+ny*ny+nz*nz); nx,ny,nz=nx/nl,ny/nl,nz/nl
  P.diff = math.max(0, nx*LD[1]+ny*LD[2]+nz*LD[3])
  -- view dir from point to camera
  local vx,vy,vz = -X, G.h-Y, -Z; local vl=math.sqrt(vx*vx+vy*vy+vz*vz); vx,vy,vz=vx/vl,vy/vl,vz/vl
  local d = vx*nx+vy*ny+vz*nz
  local rx,ry,rz = 2*d*nx-vx, 2*d*ny-vy, 2*d*nz-vz
  local ang = math.acos(clamp(rx*SC[1]+ry*SC[2]+rz*SC[3], -1, 1))
  P.spec = ang / DISC   -- <1 reflects the disc
end
LIPS = {
  pile{{"lead white",4},{"lemon chrome",0.4}},
  pile{{"lead white",3},{"cadmium yellow",0.8},{"yellow ochre",0.5}},
  pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",1.2}},
}
DARKS = {
  pile{{"raw sienna",2},{"bone black",0.7},{"burnt sienna",1}},
  pile{{"burnt sienna",2},{"bone black",1},{"bone brown",1}},
  pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.6}},
}
function paint_rims(list, o)
  o = o or {}
  local lip = brush{kind="round", width=3, point=0.7}
  local dk = brush{kind="round", width=8, point=0.3}
  local n=0
  for _,P in ipairs(list) do
    local minx,maxx,miny,maxy=1e9,-1e9,1e9,-1e9
    for _,q in ipairs(P.pts) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
    local h = maxy-miny
    local inview = maxx>-10 and minx<1010 and miny<1276 and maxy > G.limbY(clamp((minx+maxx)/2,0,1000))+1
    if inview and (not o.filter or o.filter(P)) then
      n=n+1
      local s = P.spec
      local li = (s<1.0) and 1 or (s<1.6 and 2 or 3)
      local di = (s<1.0) and 1 or (s<1.7 and 2 or 3)
      local away = math.cos(P.th) > -0.15
      -- keep the rim inside the dome
      local rim = {}
      for _,q in ipairs(P.rim2) do rim[#rim+1] = {q[1], math.max(q[2], G.limbY(clamp(q[1],0,1000))+1)} end
      local bw = clamp(h*(away and 0.10 or 0.16), 0.8, 16)
      if bw > 1.2 then
        local sh = {} for _,q in ipairs(rim) do sh[#sh+1] = {q[1], q[2] + bw*0.55} end
        dk:reload(DARKS[di], 0.7)
        dk:stroke(sh, {pressure={dk:pressure_for(bw), dk:pressure_for(bw)}, swell={0.4,1,1,0.4}})
      end
      local lw = clamp(h*0.045, 0.5, 3.2)
      lip:reload(LIPS[li], 0.65)
      lip:stroke(rim, {pressure={lip:pressure_for(lw)*0.6, lip:pressure_for(lw)*0.6}, swell={0.2,1,1,0.3}})
    end
  end
  return n
end
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local n = paint_rims(PL, {filter=function(P) local l=G.limbY(clamp(P.x,0,1000)) return P.y < l + 135 and M.all:at(P.x,P.y) < 0.5 end})
print(n)

--@ chunk 66
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-1 end) - E(1.0)
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local g = pile{{"burnt sienna",1.2},{"bone brown",1},{"rose madder",0.3}, medium=0.6}
local ring = (E(1.62)-E(1.2)):soften(25) * skyOnly
work(ring, {hand="glaze", pile=g, angle=tan, clip=skyOnly - E(1.12), coverage=1.6})
local g2 = pile{{"bone black",1},{"burnt sienna",0.6},{"ultramarine blue",0.4}, medium=0.55}
local outer = (E(1.95)-E(1.42)):soften(30) * skyOnly
work(outer, {hand="glaze", pile=g2, angle=tan, clip=skyOnly - E(1.3), coverage=1.3})

--@ chunk 67
print(wait(24*60)); print(drying(250,700), drying(610,680), drying(700,700), drying(441,760))

--@ chunk 68
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1)
local lim = function(x) return G.limbY(x) end
local domeC = below(function(x) return lim(x)+0.5 end) - fg
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
local gy = pile{{"Indian yellow",1},{"cadmium yellow",0.4},{"raw sienna",0.3}, medium=0.7}
local band = (below(function(x) return lim(x) end) * above(function(x) return lim(x)+150 end)):soften(30)
work(band - fg, {hand="glaze", pile=gy, angle=horiz, clip=domeC, coverage=1.3})

--@ chunk 69
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1)
local lim = function(x) return G.limbY(x) end
local domeC = below(function(x) return lim(x)+0.5 end) - fg
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
local gr = pile{{"burnt sienna",1},{"rose madder",0.5},{"Mars orange",0.3}, medium=0.75}
local band = (below(function(x) return lim(x) end) * above(function(x) return lim(x)+160 end)):soften(30)
work(band - fg, {hand="glaze", pile=gr, angle=horiz, clip=domeC, coverage=1.2})
blend(band - fg, {angle=horiz, tool={kind="badger", width=30}, pressure={0.25,0.4}})

--@ chunk 70
print(wait(60*60)); print(drying(250,700), drying(610,680), drying(441,760), drying(514,750))

--@ chunk 71
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local knees = ellipse(441,736,19,13) + ellipse(514,713,18,12) + ellipse(437,832,15,9) + ellipse(522,804,14,8) + ellipse(447,618,24,14) + ellipse(494,617,23,14)
local parts = poly({{600,712},{611,710},{625,742},{614,748}}, true) + poly({{596,690},{607,689},{609,720},{597,722}}) + poly({{601,828},{617,826},{620,856},{600,858}}, true)
local legs = (M.legs + knees) * below(function(x) return 640 end)
local rifle = (M.rifle + parts) * below(function(x) return 645 end)
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
work(legs + rifle, {hand="body", pile=dk, coverage=3.5, fill=true, clip=true, tool="filbert 5", angle=math.pi/2})
local f8 = brush{kind="filbert", width=12}
local warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.4}}
for _,s in ipairs({{{439,770},{438,800},{437,832}}, {{519,750},{521,778},{522,800}}, {{442,690},{441,725}}, {{510,680},{513,705}}}) do
  f8:reload(warm, 0.3); f8:stroke(s, {pressure={0.4,0.55}, clip=legs})
end
blend(legs, {angle=math.pi/2, tool={kind="badger", width=12}, pressure={0.25,0.45}})

--@ chunk 72
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local side = poly({{462,830},{475,837},{495,841},{512,842},{530,841},{549,837},{562,830},{561,852},{548,860},{530,864},{512,865},{494,864},{476,860},{464,852}}, true)
local top = ellipse(512, 830, 50, 11)
local dkb = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local tb = pile{{"yellow ochre",1.5},{"burnt sienna",1},{"lead white",0.5},{"bone black",0.2}}
work(side - fg, {hand="detail", pile=dkb, coverage=3, fill=true, clip=side - fg})
work(top - fg, {hand="detail", pile=tb, coverage=3, fill=true, clip=top - fg})
local r = brush{kind="round", width=2.5, point=0.6}
-- far lip of the boss top catching the Sun, and the near edge in shadow
line(r, FP.lit, {{463,828},{480,821},{512,819},{545,821},{561,828}}, 0.6, 0.4, {clip=-fg})
line(r, FP.warm, {{464,833},{485,840},{512,842},{540,840},{560,833}}, 0.5, 0.35, {clip=-fg})
-- an engraved ring on its flank, re-cut until soft: bone inlay
local bi = pile{{"lead white",2},{"yellow ochre",1},{"burnt sienna",0.4},{"bone black",0.2}}
line(r, bi, {{466,846},{486,852},{512,854},{538,852},{558,846}}, 0.3, 0.3, {clip=side - fg})
-- warm bounce low on the flank
line(brush{kind="filbert", width=6}, FP.warm, {{470,856},{512,861},{555,855}}, 0.3, 0.35, {clip=side - fg})

--@ chunk 73
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local wedge = poly({{418,857},{462,861},{470,850},{545,836},{566,850},{622,858},{430,1266},{70,1266}}, true)
local shp = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"burnt sienna",0.6},{"bone brown",0.6}, medium=0.35}
local dir = math.atan(1, -0.64)
work(wedge - fg, {hand="body", pile=shp, coverage=2.2, angle=dir, edge="soft", load=0.45, clip=below(function(x) return 845 end) - fg, tool="filbert 14", length={40,120}})
-- the darkest core right under the feet
local core = poly({{420,858},{560,846},{600,880},{380,920}}, true)
work(core - fg, {hand="body", pile=shp, coverage=2, angle=dir, edge="soft", load=0.5, clip=below(function(x) return 850 end) - fg, tool="filbert 8"})

--@ chunk 74
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local wedge = poly({{418,857},{462,861},{470,850},{545,836},{566,850},{622,858},{430,1266},{70,1266}}, true):grow(25)
local dir = math.atan(1, -0.64)
blend(wedge * below(function(x) return 852 end) - fg, {angle=dir, tool={kind="badger", width=30}, pressure={0.3,0.5}})
blend(wedge * below(function(x) return 900 end) - fg, {angle=dir+math.pi/2, tool={kind="badger", width=40}, pressure={0.2,0.35}})

--@ chunk 75
print(wait(60*60)); print(drying(300,1100), drying(450,900), drying(512,850))

--@ chunk 76
print(wait(96*60)); print(drying(300,1100), drying(450,900), drying(512,850))

--@ chunk 77
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
SHU = {-0.539, 0.842}
function shadow_ribbon(x0, y0, hw0, k, tmax)
  local pts, ws = {}, {}
  for t=0,tmax,40 do pts[#pts+1] = {x0 + SHU[1]*t, y0 + SHU[2]*t}; ws[#ws+1] = 2*(hw0 + k*t) end
  return ribbon(pts, ws)
end
function shadow_mask()
  return shadow_ribbon(437, 858, 17, 0.06, 520) + shadow_ribbon(523, 836, 15, 0.06, 540) + shadow_ribbon(611, 856, 8, 0.035, 520)
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local boss = ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)
local carpet = poly({{418,857},{462,861},{470,850},{545,836},{566,850},{622,858},{430,1266},{70,1266}}, true):grow(30)
local S = shadow_mask()
local lit = carpet * below(function(x) return 838 end) - S - fg - boss
local hull = pile{{"burnt sienna",2},{"bone black",0.9},{"yellow ochre",1},{"rose madder",0.15}}
local hull2 = pile{{"burnt sienna",1.5},{"yellow ochre",1},{"bone black",0.5},{"lead white",0.2}}
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
work(lit, {hand="body", pile=hull, coverage=3, fill=true, angle=horiz, clip=lit, tool="filbert 10"})
work(lit * above(function(x) return 1000 end), {hand="scumble", pile=hull2, coverage=1.2, angle=horiz, clip=lit, load=0.35, tool="filbert 8"})

--@ chunk 78
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
SHU = {-0.539, 0.842}
function shadow_ribbon(x0, y0, hw0, k, tmax)
  local pts, ws = {}, {}
  for t=0,tmax,40 do pts[#pts+1] = {x0 + SHU[1]*t, y0 + SHU[2]*t}; ws[#ws+1] = 2*(hw0 + k*t) end
  return ribbon(pts, ws)
end
function shadow_mask()
  return shadow_ribbon(437, 858, 17, 0.06, 520) + shadow_ribbon(523, 836, 15, 0.06, 540) + shadow_ribbon(611, 856, 8, 0.035, 520)
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local boss = ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)
local carpet = poly({{418,857},{462,861},{470,850},{545,836},{566,850},{622,858},{430,1266},{70,1266}}, true):grow(30)
local S = shadow_mask()
local lit = carpet * below(function(x) return 838 end) - S - fg - boss
local dk = pile{{"bone brown",2},{"ultramarine blue",0.5},{"burnt sienna",0.8},{"bone black",0.4}}
local horiz = function(x,y) return 0.2*math.atan((x-470)/900, 1) end
work(lit, {hand="body", pile=dk, coverage=2.2, fill=true, angle=horiz, clip=lit, tool="filbert 10"})
blend(lit:grow(12) - fg - boss, {angle=horiz, tool={kind="badger", width=24}, pressure={0.3,0.5}})

--@ chunk 79
print(wait(72*60)); print(drying(300,1100), drying(450,900), drying(512,850), drying(800,1000))

--@ chunk 80
print(wait(72*60)); print(drying(300,1100), drying(450,900), drying(512,850), drying(480,870))

--@ chunk 81
print(wait(120*60)); print(drying(300,1100), drying(450,900), drying(512,850), drying(480,870))

--@ chunk 82
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
SHU = {-0.539, 0.842}
function shadow_ribbon(x0, y0, hw0, k, tmax)
  local pts, ws = {}, {}
  for t=0,tmax,40 do pts[#pts+1] = {x0 + SHU[1]*t, y0 + SHU[2]*t}; ws[#ws+1] = 2*(hw0 + k*t) end
  return ribbon(pts, ws)
end
function shadow_mask()
  return shadow_ribbon(437, 858, 17, 0.06, 520) + shadow_ribbon(523, 836, 15, 0.06, 540) + shadow_ribbon(611, 856, 8, 0.035, 520)
end
local M = fig_masks()
local boss = ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)
local excl = M.all:grow(0.5) + boss
local topc = function(x) return 862 + 0.0004*(x-490)^2 end
FGREG_TOP = topc
local region = below(topc) - excl
local F1 = pile{{"burnt sienna",2},{"bone black",0.8},{"rose madder",0.3},{"yellow ochre",0.4}}
local F2 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5},{"bone black",0.3}}
local horiz = function(x,y) return 0.25*math.atan((x-490)/700, 1) end
local upper = region * above(function(x) return 1010 + 0.0003*(x-490)^2 end)
local lower = region - upper
work(lower, {hand="broad", pile=F2, coverage=3, fill=true, angle=horiz, clip=region, edge="soft"})
work(upper, {hand="body", pile=F1, coverage=3, fill=true, angle=horiz, clip=region, edge="lost", tool="filbert 14"})

--@ chunk 83
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
SHU = {-0.539, 0.842}
function shadow_ribbon(x0, y0, hw0, k, tmax)
  local pts, ws = {}, {}
  for t=0,tmax,40 do pts[#pts+1] = {x0 + SHU[1]*t, y0 + SHU[2]*t}; ws[#ws+1] = 2*(hw0 + k*t) end
  return ribbon(pts, ws)
end
function shadow_mask()
  return shadow_ribbon(437, 858, 17, 0.06, 520) + shadow_ribbon(523, 836, 15, 0.06, 540) + shadow_ribbon(611, 856, 8, 0.035, 520)
end
local M = fig_masks()
local boss = ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)
local excl = M.all:grow(0.5) + boss
local S = (shadow_ribbon(437, 862, 15, 0.035, 500) + shadow_ribbon(523, 866, 13, 0.035, 500) + shadow_ribbon(611, 860, 6, 0.02, 480)) - excl
local SH = pile{{"bone black",1.5},{"ultramarine blue",0.7},{"burnt sienna",0.5}}
local dir = math.atan(SHU[2], SHU[1])
work(S, {hand="body", pile=SH, coverage=2.5, fill=true, angle=dir, edge="soft", tool="filbert 10", length={40,90}})

--@ chunk 84
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local boss = ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)
local excl = M.all:grow(0.5) + boss
local region = below(function(x) return 850 + 0.0004*(x-490)^2 end) - excl
local horiz = function(x,y) return 0.25*math.atan((x-490)/700, 1) end
blend(region, {angle=function(x,y) return horiz(x,y)+1.2 end, tool={kind="badger", width=30}, pressure={0.3,0.5}})
blend(region, {angle=horiz, tool={kind="badger", width=40}, pressure={0.25,0.4}})

--@ chunk 85
print(wait(120*60)); print(drying(300,1100), drying(450,900), drying(700,950), drying(480,880))

--@ chunk 86
-- sun direction in world: through canvas point SUN center
function G.unproj(x,y)
  local c,s=math.cos(G.pitch),math.sin(G.pitch)
  local Xp=(x-G.cx)/G.F; local Yp=(G.cy-y)/G.F; local Zp=1
  local Y=Yp*c - Zp*s; local Z=Yp*s + Zp*c
  local l=math.sqrt(Xp*Xp+Y*Y+Z*Z) return Xp/l,Y/l,Z/l
end
SD = {G.unproj(SUN.x, SUN.y)}
PA,PP,PN=0.14,0.62,2500
local GA = math.pi*(3-math.sqrt(5))
local a, p = PA or 0.15, PP or 0.75
local cam = {0, G.h, 0}
function G.domeN(r,th)
  local X,Y,Z = G.dome(r,th)
  return X/G.R, (Y+G.R)/G.R, (Z-G.Zc)/G.R
end
PL = {}
local rng = noise{seed=77, octaves=1, period=3}
for i=2,(PN or 560) do
  local r = a*i^p * (1 + 0.025*rng(i*1.7, 3))
  local th = i*GA + 0.03*rng(i*2.3, 9)
  local X,Y,Z = G.dome(r,th)
  local nx,ny,nz = G.domeN(r,th)
  local vx,vy,vz = cam[1]-X, cam[2]-Y, cam[3]-Z
  local vl = math.sqrt(vx*vx+vy*vy+vz*vz)
  local facing = (nx*vx+ny*vy+nz*vz)/vl
  local cx,cy,cz = G.proj(X,Y,Z)
  if facing > 0.004 and cz > 0.25 and cx > -350 and cx < 1350 and cy < 1700 then
    local area = 2*math.pi*r*a*p*i^(p-1)
    local s = math.sqrt(area) * (1 + 0.07*rng(i*3.1, 17))
    local L, Wd = 1.4*s, 1.2*s
    -- local frame
    local dr = 0.01
    local X2,Y2,Z2 = G.dome(r+dr,th)
    local erx,ery,erz = X2-X, Y2-Y, Z2-Z
    local el = math.sqrt(erx^2+ery^2+erz^2); erx,ery,erz = erx/el,ery/el,erz/el
    -- lateral = n x er
    local etx,ety,etz = ny*erz-nz*ery, nz*erx-nx*erz, nx*ery-ny*erx
    local pts, rim = {}, {}
    local n = 28
    for k=0,n-1 do
      local s0 = k/n*2*math.pi
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = (cs > 0) and 0.58*L*cs or 0.42*L*cs
      local v = 0.5*Wd*sn*(cs < 0 and (0.75+0.25*(1+cs)) or 1)
      local lift = 0.06*L*(u/L+0.45)
      local PX = X + erx*u + etx*v + nx*lift
      local PY = Y + ery*u + ety*v + ny*lift
      local PZ = Z + erz*u + etz*v + nz*lift
      local x,y = G.proj(PX,PY,PZ)
      pts[#pts+1] = {x,y}
      if cs > 0.05 then rim[#rim+1] = {x,y, cs} end
    end
    local rim2 = {}
    for k=0,16 do
      local s0 = -1.25 + 2.5*k/16
      local cs, sn = math.cos(s0), math.sin(s0)
      local u = 0.58*L*cs; local v = 0.5*Wd*sn
      local lift = 0.06*L*(u/L+0.45)
      local x,y = G.proj(X + erx*u + etx*v + nx*lift, Y + ery*u + ety*v + ny*lift, Z + erz*u + etz*v + nz*lift)
      rim2[#rim2+1] = {x,y}
    end
    PL[#PL+1] = {rim2=rim2, i=i, r=r, th=th, x=cx, y=cy, z=cz, pts=pts, rim=rim, facing=facing, L=L, nx=nx,ny=ny,nz=nz}
  end
end
table.sort(PL, function(A,B) return A.r > B.r end)
print("plates", #PL)
-- per-plate light: diffuse from upper sun, specular from the whole disc
local LD = {G.unproj(SUN.x, SUN.y-230)}
local SC = {G.unproj(SUN.x, SUN.y)}
local DISC = math.atan(SUN.r/G.F)
local jn = noise{seed=31, octaves=1, period=1.3}
for _,P in ipairs(PL) do
  local X,Y,Z = G.dome(P.r,P.th)
  -- plate normal: dome normal tilted toward apex by lift slope, plus handmade wobble
  local X2,Y2,Z2 = G.dome(P.r+0.01,P.th)
  local ex,ey,ez = X2-X,Y2-Y,Z2-Z; local el=math.sqrt(ex*ex+ey*ey+ez*ez); ex,ey,ez=ex/el,ey/el,ez/el
  local tilt = 0.10 + 0.05*jn(P.i*1.1,1)
  local wob1, wob2 = 0.06*jn(P.i*0.7,5), 0.06*jn(P.i*0.9,8)
  local nx = P.nx - ex*tilt + wob1
  local ny = P.ny - ey*tilt
  local nz = P.nz - ez*tilt + wob2
  local nl = math.sqrt(nx*nx+ny*ny+nz*nz); nx,ny,nz=nx/nl,ny/nl,nz/nl
  P.diff = math.max(0, nx*LD[1]+ny*LD[2]+nz*LD[3])
  -- view dir from point to camera
  local vx,vy,vz = -X, G.h-Y, -Z; local vl=math.sqrt(vx*vx+vy*vy+vz*vz); vx,vy,vz=vx/vl,vy/vl,vz/vl
  local d = vx*nx+vy*ny+vz*nz
  local rx,ry,rz = 2*d*nx-vx, 2*d*ny-vy, 2*d*nz-vz
  local ang = math.acos(clamp(rx*SC[1]+ry*SC[2]+rz*SC[3], -1, 1))
  P.spec = ang / DISC   -- <1 reflects the disc
end
LIPS = {
  pile{{"lead white",4},{"lemon chrome",0.4}},
  pile{{"lead white",3},{"cadmium yellow",0.8},{"yellow ochre",0.5}},
  pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",1.2}},
}
DARKS = {
  pile{{"raw sienna",2},{"bone black",0.7},{"burnt sienna",1}},
  pile{{"burnt sienna",2},{"bone black",1},{"bone brown",1}},
  pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.6}},
}
function paint_rims(list, o)
  o = o or {}
  local lip = brush{kind="round", width=3, point=0.7}
  local dk = brush{kind="round", width=8, point=0.3}
  local n=0
  for _,P in ipairs(list) do
    local minx,maxx,miny,maxy=1e9,-1e9,1e9,-1e9
    for _,q in ipairs(P.pts) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
    local h = maxy-miny
    local inview = maxx>-10 and minx<1010 and miny<1276 and maxy > G.limbY(clamp((minx+maxx)/2,0,1000))+1
    if inview and (not o.filter or o.filter(P)) then
      n=n+1
      local s = P.spec
      local li = (s<1.0) and 1 or (s<1.6 and 2 or 3)
      local di = (s<1.0) and 1 or (s<1.7 and 2 or 3)
      local away = math.cos(P.th) > -0.15
      -- keep the rim inside the dome
      local rim = {}
      for _,q in ipairs(P.rim2) do rim[#rim+1] = {q[1], math.max(q[2], G.limbY(clamp(q[1],0,1000))+1)} end
      local bw = clamp(h*(away and 0.10 or 0.16), 0.8, 16)
      if bw > 1.2 then
        local sh = {} for _,q in ipairs(rim) do sh[#sh+1] = {q[1], q[2] + bw*0.55} end
        dk:reload(DARKS[di], 0.7)
        dk:stroke(sh, {pressure={dk:pressure_for(bw), dk:pressure_for(bw)}, swell={0.4,1,1,0.4}})
      end
      local lw = clamp(h*0.045, 0.5, 3.2)
      lip:reload(LIPS[li], 0.65)
      lip:stroke(rim, {pressure={lip:pressure_for(lw)*0.6, lip:pressure_for(lw)*0.6}, swell={0.2,1,1,0.3}})
    end
  end
  return n
end
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local boss = ellipse(512, 830, 50, 11)
local n = paint_rims(PL, {filter=function(P)
  local minx,maxx,miny,maxy=1e9,-1e9,1e9,-1e9
  for _,q in ipairs(P.rim2) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
  return maxy > 862 + 0.0004*(P.x-490)^2 and M.all:at(P.x, (miny+maxy)/2) < 0.5 end})
print(n)

--@ chunk 87
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
SHU = {-0.539, 0.842}
function shadow_ribbon(x0, y0, hw0, k, tmax)
  local pts, ws = {}, {}
  for t=0,tmax,40 do pts[#pts+1] = {x0 + SHU[1]*t, y0 + SHU[2]*t}; ws[#ws+1] = 2*(hw0 + k*t) end
  return ribbon(pts, ws)
end
function shadow_mask()
  return shadow_ribbon(437, 858, 17, 0.06, 520) + shadow_ribbon(523, 836, 15, 0.06, 540) + shadow_ribbon(611, 856, 8, 0.035, 520)
end
local M = fig_masks()
local boss = ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)
local excl = M.all:grow(0.5) + boss
local S = (shadow_ribbon(437, 862, 15, 0.04, 520) + shadow_ribbon(523, 866, 13, 0.04, 520) + shadow_ribbon(611, 860, 6, 0.025, 500)) - excl
local SH = pile{{"bone black",1.5},{"ultramarine blue",0.7},{"burnt sienna",0.5}, medium=0.35}
local dir = math.atan(SHU[2], SHU[1])
work(S, {hand="body", pile=SH, coverage=2.2, fill=true, angle=dir, edge="soft", tool="filbert 10", length={40,90}})

--@ chunk 88
local cx,cy,r = SUN.x,SUN.y,SUN.r
local st = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.4}}
local n=0
for k=1,46 do
  local a = rand(-math.pi-0.15, 0.1)
  if rand(0,1)<0.5 then a = (rand(0,1)<0.5 and -2.45 or -0.7) + randn(0,0.22) end
  local r0 = r*rand(1.03,1.1); local L = r*rand(0.18,0.5)
  local x0,y0 = cx+r0*math.cos(a), cy+r0*math.sin(a)
  local x1,y1 = cx+(r0+L)*math.cos(a+randn(0,0.02)), cy+(r0+L)*math.sin(a+randn(0,0.02))
  if y0 < G.limbY(clamp(x0,0,1000)) - 5 and y1 < G.limbY(clamp(x1,0,1000)) - 5 then
    local b = brush{kind="filbert", width=rand(5,9)}
    b:load(st, rand(0.1,0.18))
    b:stroke({{x0,y0},{(x0+x1)/2,(y0+y1)/2},{x1,y1}}, {pressure={0.35,0.1}, ramps={0.05,0.6}})
    n=n+1
  end
end
-- stars: few, clustered, only far from the Sun
local sw = pile{{"lead white",4},{"cerulean blue",0.1}}
local stars=0
for k=1,140 do
  local x,y = rand(0,1000), rand(0,560)
  local d = math.sqrt((x-cx)^2+(y-cy)^2)/r
  if d > 1.95 + rand(0,0.3) and y < G.limbY(clamp(x,0,1000))-10 then
    local b = brush{kind="round", width=rand(0.8,2.2), point=0.5}
    b:load(sw, 0.6); b:touch(x, y, {pressure=rand(0.2,0.6)}); stars=stars+1
  end
end
for _,p in ipairs({{70,90},{905,48},{140,310}}) do
  local b = brush{kind="round", width=3.2, point=0.4}; b:load(sw,0.8); b:touch(p[1],p[2],{pressure=0.7})
end
print(n, stars)

--@ chunk 89
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-3 end) - E(1.01)
local rad=function(x,y) return math.atan(y-cy,x-cx) end
blend(skyOnly*E(1.65), {angle=rad, tool={kind="badger", width=14}, pressure={0.3,0.5}})

--@ chunk 90
print(wait(72*60)); print(drying(250,350), drying(512,830), drying(470,470), drying(300,1100))

--@ chunk 91
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-3 end) - E(1.005) - fg
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local gw = pile{{"Indian yellow",1},{"Mars orange",0.6},{"cadmium yellow",0.3}, medium=0.7}
work(skyOnly*E(1.6), {hand="glaze", pile=gw, angle=tan, clip=skyOnly, coverage=1.2})
local boss = (ellipse(512, 830, 50, 11) + poly({{462,830},{562,830},{561,852},{512,865},{464,852}}, true)) - fg
local gb = pile{{"bone brown",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}, medium=0.4}
work(boss, {hand="body", pile=gb, coverage=2, fill=true, clip=boss, tool="filbert 6", angle=0, load=0.5})

--@ chunk 92
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-3 end) - E(1.005) - fg
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad=function(x,y) return math.atan(y-cy,x-cx) end
blend(skyOnly*E(1.75), {angle=rad, tool={kind="badger", width=30}})
blend(skyOnly*E(1.75), {angle=tan, tool={kind="badger", width=40}, pressure={0.25,0.4}})

--@ chunk 93
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
local M = fig_masks()
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
local cp = pile{{"bone black",1},{"rose madder",1},{"burnt sienna",1},{"ultramarine blue",0.3}}
-- helmet: dark, then a warm bounce low on the back and the Sun's rim on top
work(M.head, {hand="detail", pile=dk, coverage=3.5, fill=true, clip=true})
local f = brush{kind="filbert", width=12}
f:load(FP.warm, 0.25); f:stroke({{448,392},{466,398},{486,392}}, {pressure={0.4,0.5}, clip=M.head})
local f4 = brush{kind="filbert", width=6}
line(f4, FP.lit, {{439,360},{447,347},{460,340},{474,339},{487,344},{495,356}}, 0.55, 0.45, {clip=M.head, swell={0.3,1,1,1,1,0.4}})
blend(M.head, {angle=math.pi/2, tool={kind="badger", width=10}, pressure={0.2,0.35}})
-- cape: fresh base and broad soft folds wet-in-wet
work(M.cape, {hand="body", pile=cp, coverage=3, fill=true, clip=true, tool="filbert 8", angle=math.pi/2})
local ridge = pile{{"rose madder",1},{"burnt sienna",0.8},{"vermilion",0.5},{"lead white",0.15}}
local valley = pile{{"bone black",1.3},{"rose madder",0.6},{"ultramarine blue",0.3}}
local fb = brush{kind="filbert", width=16}
local folds = {
  {{{410,430},{404,490},{400,555}}, ridge, 0.35},
  {{{438,428},{436,490},{434,550}}, valley, 0.45},
  {{{462,432},{462,490},{462,545}}, ridge, 0.3},
  {{{492,430},{495,485},{496,538}}, valley, 0.45},
  {{{524,426},{532,475},{536,528}}, ridge, 0.35},
}
for _,fd in ipairs(folds) do fb:load(fd[2], fd[3]); fb:stroke(fd[1], {pressure={0.35,0.55}, clip=M.cape}) end
-- shoulder tops catching the Sun
local fs = brush{kind="filbert", width=9}
fs:load(FP.crim, 0.45); fs:stroke({{396,432},{408,418},{428,409}}, {pressure={0.4,0.4}, clip=M.cape})
fs:load(FP.crim, 0.45); fs:stroke({{508,409},{527,415},{541,430}}, {pressure={0.4,0.4}, clip=M.cape})
blend(M.cape, {angle=math.pi/2, tool={kind="badger", width=14}, pressure={0.25,0.4}})

--@ chunk 94
print(wait(96*60)); print(drying(250,350), drying(100,500), drying(470,470), drying(466,370))

--@ chunk 95
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(0.5)
local cx,cy,r = SUN.x,SUN.y,SUN.r
local E=function(f) return ellipse(cx,cy,r*f,r*f) end
local skyOnly = above(function(x) return G.limbY(x)-2 end) - E(1.0) - fg
local tan=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad=function(x,y) return math.atan(y-cy,x-cx) end
local Z = {
 {1.45,1.82, pile{{"bone black",1.5},{"burnt sienna",0.7},{"ultramarine blue",0.6},{"rose madder",0.2}}, "filbert 16"},
 {1.27,1.48, pile{{"red earth",1},{"burnt sienna",1},{"bone black",0.9}}, "filbert 14"},
 {1.13,1.3, pile{{"Mars orange",1},{"red earth",1.5},{"burnt sienna",0.5}}, "filbert 12"},
 {1.04,1.15, pile{{"cadmium yellow",1},{"Mars orange",1.2},{"lead white",0.4}}, "filbert 10"},
 {1.0,1.055, pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}, "filbert 8"},
}
for _,z in ipairs(Z) do
  work((E(z[2])-E(z[1]))*skyOnly, {hand="body", pile=z[3], coverage=3, fill=true, angle=tan, tool=z[4], clip=skyOnly})
end
blend(skyOnly*E(1.85), {angle=rad})
blend(skyOnly*E(1.8), {angle=tan, pressure={0.2,0.4}})

--@ chunk 96
print(wait(96*60)); print(drying(250,350), drying(470,470), drying(466,370), drying(600,690))

--@ chunk 97
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
FP = {
  lit = pile{{"lead white",2},{"cadmium yellow",0.6},{"yellow ochre",0.4}},
  mid = pile{{"bone black",1},{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.3}},
  warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.3},{"lead white",0.2}},
  seam = pile{{"bone black",2},{"ultramarine blue",0.5}},
  bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}},
  crim = pile{{"vermilion",1},{"rose madder",1},{"lead white",0.3}},
  crimdk = pile{{"rose madder",1},{"bone black",1},{"burnt sienna",0.5}},
}
function line(br, p, pts, load, pr, opts)
  br:reload(p, load)
  local o = {pressure={pr, pr}}
  if opts then for k,v in pairs(opts) do o[k]=v end end
  br:stroke(pts, o)
end
local M = fig_masks()
local hot = pile{{"lead white",3},{"lemon chrome",0.4},{"cadmium yellow",0.2}}
local clothhot = pile{{"vermilion",1},{"lead white",1},{"cadmium yellow",0.4}}
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.8}}
local r3 = brush{kind="round", width=3.5, point=0.7}
local r2 = brush{kind="round", width=2.2, point=0.7}
-- the Sun catching the crown of the helmet
line(r3, hot, {{441,356},{448,346},{458,340},{470,338},{482,341},{491,349},{496,360}}, 0.6, 0.5, {clip=M.head:grow(1), swell={0.3,0.8,1,1,1,0.8,0.3}})
line(r2, hot, {{497,366},{498,380},{494,392}}, 0.45, 0.3, {clip=M.head:grow(1), swell={1,0.6,0.2}})
-- shoulders of the cape, hot red-gold edge
line(r3, clothhot, {{392,438},{400,424},{414,413},{430,406}}, 0.55, 0.45, {clip=M.cape:grow(1), swell={0.4,1,1,0.5}})
line(r3, clothhot, {{508,406},{526,412},{540,424},{548,440}}, 0.55, 0.45, {clip=M.cape:grow(1), swell={0.5,1,1,0.4}})
-- arms: thin rims on the edges toward the light
line(r2, hot, {{379,525},{378,565},{381,604}}, 0.45, 0.3, {clip=M.arms:grow(1)})
line(r2, hot, {{556,508},{566,535},{582,570}}, 0.45, 0.3, {clip=M.arms:grow(1)})
line(r2, hot, {{580,537},{587,536}}, 0.5, 0.35, {})
-- antenna restated, with a spark at its tip
line(brush{kind="round", width=2, point=0.5}, dk, {{424,416},{420,380},{417,340},{415,312}}, 0.8, 0.45, {})
local t = brush{kind="round", width=3, point=0.3}; t:load(hot, 0.8); t:touch(415, 311, {pressure=0.6})
-- the worn cross, rubbed nearly away
local bonew = pile{{"lead white",1},{"yellow ochre",1},{"burnt sienna",0.5},{"rose madder",0.3}}
local fc = brush{kind="filbert", width=7}
line(fc, bonew, {{468,436},{468,474},{469,512}}, 0.12, 0.5, {clip=M.cape})
line(fc, bonew, {{445,460},{468,459},{492,458}}, 0.12, 0.5, {clip=M.cape})
-- a rosary hanging from the left hand: dark beads with glints, a small cross
local bead = brush{kind="round", width=2.6, point=0.2}
for i=0,9 do
  local y = 652 + i*5.2; local x = 395 + 1.5*math.sin(i*0.5)
  bead:load(dk, 0.8); bead:touch(x, y, {pressure=0.55})
  if i%3==1 then local g=brush{kind="round", width=1.2, point=0.3}; g:load(hot,0.7); g:touch(x+0.6, y-0.6, {pressure=0.4}) end
end
line(brush{kind="round", width=2.2, point=0.3}, dk, {{396,705},{396,717}}, 0.8, 0.6, {})
line(brush{kind="round", width=2, point=0.3}, dk, {{392,709},{400,709}}, 0.8, 0.6, {})
local g=brush{kind="round", width=1.2, point=0.3}; g:load(hot,0.7); g:touch(397, 707, {pressure=0.4})

--@ chunk 98
FIG = {}
FIG.head = {{466,336},{482,338},{494,348},{499,364},{498,382},{492,396},{480,404},{466,406},{452,404},{440,396},{435,380},{436,362},{442,348},{453,339}}
FIG.hood = {{428,406},{446,395},{468,399},{490,395},{508,406},{506,418},{468,422},{430,418}}
FIG.cape = {{430,404},{410,411},{395,423},{387,442},{383,472},{382,505},{385,540},{389,562},{400,558},{411,566},{424,553},{438,560},{452,549},{467,552},{482,541},{498,545},{513,533},{529,537},{544,525},{551,500},{553,470},{549,442},{540,424},{526,412},{506,404}}
FIG.torso = {{420,530},{520,526},{514,560},{506,590},{430,590},{424,560}}
FIG.pelvis = {{420,584},{516,584},{522,606},{514,628},{494,633},{470,626},{446,633},{426,628},{416,606}}
FIG.lthigh = {{446,612},{443,675},{441,735}}; FIG.lthighW = {44,40,32}
FIG.lshin = {{441,735},{440,772},{438,805},{437,838}}; FIG.lshinW = {31,35,30,25}
FIG.lfoot = {{419,836},{456,836},{461,850},{458,860},{417,860},{415,849}}
FIG.rthigh = {{494,612},{505,662},{514,712}}; FIG.rthighW = {42,38,31}
FIG.rshin = {{514,712},{518,745},{521,780},{522,806}}; FIG.rshinW = {30,33,29,24}
FIG.rfoot = {{506,804},{538,804},{543,818},{540,828},{505,828},{503,817}}
FIG.larm = {{394,515},{392,560},{394,612}}; FIG.larmW = {31,28,23}
FIG.lhand = {{383,606},{405,606},{410,626},{404,645},{391,647},{381,630}}
FIG.rarm = {{546,512},{558,548},{575,586}}; FIG.rarmW = {31,27,23}
FIG.rhand = {{566,574},{590,571},{596,590},{590,606},{572,606},{564,592}}
FIG.rifle = {{583,546},{587,600},{592,650},{598,710},{603,770},{608,852}}; FIG.rifleW = {7,8,9,13,17,22}
FIG.boss = {cx=515, cy=832, rx=56, ry=15, hgt=22}
function fig_masks()
  local M = {}
  M.head = poly(FIG.head, true)
  M.hood = poly(FIG.hood, true)
  M.cape = poly(FIG.cape, true)
  M.torso = poly(FIG.torso, true)
  M.pelvis = poly(FIG.pelvis, true)
  M.legs = ribbon(FIG.lthigh, FIG.lthighW) + ribbon(FIG.lshin, FIG.lshinW) + poly(FIG.lfoot, true)
         + ribbon(FIG.rthigh, FIG.rthighW) + ribbon(FIG.rshin, FIG.rshinW) + poly(FIG.rfoot, true)
  M.arms = ribbon(FIG.larm, FIG.larmW) + poly(FIG.lhand, true) + ribbon(FIG.rarm, FIG.rarmW) + poly(FIG.rhand, true)
  M.rifle = ribbon(FIG.rifle, FIG.rifleW)
  M.body = M.torso + M.pelvis + M.legs + M.arms + M.head
  M.all = M.body + M.cape + M.hood + M.rifle
  return M
end
local M = fig_masks()
local fg = M.all:grow(1.5)
local lim = function(x) return G.limbY(x) end
local band = below(function(x) return lim(x)+1.5 end) * above(function(x) return lim(x)+110 end) - fg
local hot = pile{{"lead white",3},{"lemon chrome",0.4},{"cadmium yellow",0.2}}
stipple(band, {pile=hot, width=1.6, pressure={0.3,0.7}, cluster={0.6, 12},
  coverage=function(x,y) local d=(y-lim(x)); return 0.05*math.exp(-((x-600)/230)^2)*math.exp(-d/30) end})
