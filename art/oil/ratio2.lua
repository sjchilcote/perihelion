-- easel session "ratio2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.8, linen={18,16}, seed=2026,
  ground={{pile={{"lead white",3},{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.6}}, um=80, apply="knife", texture=0.3}}}
function rrect(x0,y0,x1,y1,r)
  local pts = {}
  local cs = {{x1-r,y0+r,-math.pi/2},{x1-r,y1-r,0},{x0+r,y1-r,math.pi/2},{x0+r,y0+r,math.pi}}
  for _,c in ipairs(cs) do for k=0,6 do local a=c[3]+k*(math.pi/2)/6
    pts[#pts+1]={c[1]+r*math.cos(a), c[2]+r*math.sin(a)} end end
  return poly(pts)
end
BEZEL = rrect(60,90,940,1060,44)
SCREEN = rrect(115,150,885,975,56)
local room = -BEZEL
work(room, {hand="broad", pile=pile{{"ultramarine blue",2},{"burnt sienna",1},{"bone black",0.6},{"lead white",0.3}}, coverage=3, fill=true, clip=true})
-- lit room planes: wall glow behind monitor, table top
work(poly{{0,0},{1000,0},{1000,380},{0,420}} - BEZEL, {hand="body", pile=pile{{"cerulean blue",1.5},{"ultramarine blue",1},{"lead white",1.2},{"bone black",0.3}}, coverage=3, fill=true, clip=true, angle=10})
work(poly{{0,1060},{1000,1060},{1000,1250},{0,1250}}, {hand="body", pile=pile{{"raw sienna",2},{"burnt sienna",1},{"ultramarine blue",0.6},{"lead white",0.6}}, coverage=3, fill=true, clip=true, angle=0})
work(BEZEL - SCREEN, {hand="body", pile=pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.6}}, coverage=3, fill=true, clip=true, angle=0})
work(SCREEN, {hand="body", pile=pile{{"cobalt blue",2},{"cerulean blue",1},{"lead white",1},{"ultramarine blue",0.5}}, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 2
local HAIR = poly{{500,300},{620,320},{700,400},{730,520},{760,880},{700,860},{640,900},{360,900},{300,860},{240,880},{270,520},{300,400},{380,320}}
work(HAIR, {hand="body", pile=pile{{"bone black",2},{"ultramarine blue",1.5},{"burnt sienna",0.4}}, coverage=3, fill=true, clip=true, angle=90})
-- facet highlights on crown
work(poly{{380,330},{500,305},{450,420}} + poly{{560,320},{660,370},{600,440}}, {hand="body", pile=pile{{"ultramarine blue",2},{"cobalt blue",1},{"lead white",0.8},{"bone black",0.4}}, coverage=3, fill=true, clip=true})
local FACE = poly{{390,470},{610,470},{630,560},{600,640},{540,690},{460,690},{400,640},{370,560}}
work(FACE, {hand="body", pile=pile{{"lead white",3},{"rose madder",0.3},{"yellow ochre",0.2}}, coverage=3, fill=true, clip=true})
-- bangs
work(poly{{380,440},{620,440},{620,500},{560,560},{520,470},{470,560},{420,480},{380,560}}, {hand="body", pile=pile{{"bone black",2},{"ultramarine blue",1.5}}, coverage=3, fill=true, clip=true})
-- neck + dress
work(poly{{475,685},{525,685},{525,730},{475,730}}, {hand="body", pile=pile{{"lead white",3},{"rose madder",0.5},{"yellow ochre",0.3}}, coverage=3, fill=true, clip=true})
work(poly{{420,730},{580,730},{610,880},{390,880}}, {hand="body", pile=pile{{"lead white",3},{"zinc white",1},{"yellow ochre",0.15}}, coverage=3, fill=true, clip=true})
work(poly{{388,870},{612,870},{614,900},{386,900}}, {hand="body", pile=pile{{"cadmium yellow",2},{"Mars orange",1}}, coverage=3, fill=true, clip=true})
-- legs and shoes
work(poly{{450,900},{475,900},{475,950},{450,950}} + poly{{525,900},{550,900},{550,950},{525,950}}, {hand="body", pile=pile{{"lead white",3},{"rose madder",0.4}}, coverage=3, fill=true, clip=true})
work(poly{{438,945},{478,945},{478,968},{434,968}} + poly{{522,945},{562,945},{566,968},{522,968}}, {hand="body", pile=pile{{"vermilion",2},{"cadmium red",1}}, coverage=3, fill=true, clip=true})
-- waving arm
work(poly{{580,740},{640,700},{660,630},{690,640},{668,720},{600,780}}, {hand="body", pile=pile{{"lead white",3},{"rose madder",0.3},{"yellow ochre",0.2}}, coverage=3, fill=true, clip=true})
work(poly{{650,580},{700,575},{715,620},{690,650},{655,640}}, {hand="body", pile=pile{{"lead white",3},{"rose madder",0.3},{"yellow ochre",0.2}}, coverage=3, fill=true, clip=true})

--@ chunk 3
local DK = pile{{"bone black",2},{"ultramarine blue",1}}
-- smiling eyes: upward arcs as faceted chevrons
work(poly{{415,560},{445,540},{475,560},{468,568},{445,553},{422,568}} + poly{{525,560},{555,540},{585,560},{578,568},{555,553},{532,568}}, {hand="detail", pile=DK, coverage=4, fill=true, clip=true})
-- smile
work(poly{{475,620},{525,620},{512,640},{488,640}}, {hand="detail", pile=pile{{"cadmium red",2},{"rose madder",1}}, coverage=4, fill=true, clip=true})
work(poly{{405,595},{435,595},{435,608},{405,608}} + poly{{565,595},{595,595},{595,608},{565,608}}, {hand="detail", pile=pile{{"lead white",2},{"rose madder",1}}, coverage=3, fill=true, clip=true})
-- title bar
work(rrect(140,175,860,215,14), {hand="body", pile=pile{{"zinc white",2},{"cerulean blue",0.3}}, coverage=3, fill=true, clip=true})
-- peeled stamp remnant: torn red corner curling at top-left
work(poly{{150,235},{215,235},{170,268},{150,268}}, {hand="body", pile=pile{{"cadmium red",2},{"vermilion",1}}, coverage=3, fill=true, clip=true})
work(poly{{215,235},{170,268},{232,262}}, {hand="body", pile=pile{{"lead white",2},{"rose madder",0.6}}, coverage=3, fill=true, clip=true})
-- his reply: amber line in a dark box low on her screen
work(rrect(180,900,820,955,10), {hand="body", pile=pile{{"bone black",2},{"ultramarine blue",1}}, coverage=3, fill=true, clip=true})
local amb = pile{{"cadmium yellow",2},{"Mars orange",1},{"lead white",0.3}}
local A = poly{{205,920},{225,920},{225,935},{205,935}}
for i,x in ipairs({245,275,330,350,372,420,445,470,510,540,560,600,625}) do A = A + poly{{x,920},{x+16,920},{x+16,935},{x,935}} end
A = A + poly{{650,916},{662,916},{662,939},{650,939}}
work(A, {hand="detail", pile=amb, coverage=4, fill=true, clip=true})
-- her speech bubble: a heart-ish warm dot trio
work(rrect(640,340,800,395,18), {hand="body", pile=pile{{"zinc white",2},{"cerulean blue",0.2}}, coverage=3, fill=true, clip=true})
-- screen glow spilling onto table and bezel lip
work(poly{{140,1060},{860,1060},{1000,1250},{0,1250}}, {hand="glaze", pile=pile{{"cerulean blue",1},{"lead white",1}}, load=0.25, pressure=0.2, coverage=1.5, fill=true, clip=true, angle=0})

--@ chunk 4
wait(2880)
local FACE = poly{{390,500},{610,500},{630,560},{600,640},{540,690},{460,690},{400,640},{370,560}}
local HAIRL = poly{{300,400},{380,330},{390,500},{370,560},{400,640},{420,730},{390,880},{300,860},{240,880},{270,520}}
local HAIRR = poly{{700,400},{620,330},{610,500},{630,560},{600,640},{580,730},{610,880},{700,860},{760,880},{730,520}}
local HK = pile{{"bone black",2.5},{"ultramarine blue",1},{"burnt sienna",0.5}}
work(HAIRL, {hand="body", pile=HK, coverage=4, fill=true, clip=true, angle=95})
work(HAIRR - poly{{580,740},{640,700},{660,630},{690,640},{668,720},{600,780}} - poly{{650,580},{700,575},{715,620},{690,650},{655,640}}, {hand="body", pile=HK, coverage=4, fill=true, clip=true, angle=85})
-- lit facet planes on hair, catching screen glow
work(poly{{300,420},{340,380},{330,700},{290,760}}, {hand="body", pile=pile{{"ultramarine blue",2},{"cobalt blue",1},{"bone black",0.5}}, coverage=3, fill=true, clip=true})
work(poly{{700,420},{660,380},{680,700},{720,760}}, {hand="body", pile=pile{{"ultramarine blue",2},{"cobalt blue",1},{"bone black",0.5}}, coverage=3, fill=true, clip=true})
-- warm lit facet of face (screen light from front)
work(poly{{500,520},{605,520},{625,565},{595,640},{540,688},{500,640}}, {hand="body", pile=pile{{"lead white",3},{"Indian yellow",0.15},{"rose madder",0.2}}, coverage=2, fill=true, clip=true})

--@ chunk 5
local SK = pile{{"lead white",3},{"rose madder",0.2},{"yellow ochre",0.1}}
local FACE = poly{{395,480},{605,480},{628,560},{600,640},{540,688},{460,688},{400,640},{372,560}}
work(FACE, {hand="body", pile=SK, coverage=4, fill=true, clip=true})
work(poly{{475,688},{525,688},{525,730},{475,730}}, {hand="body", pile=SK, coverage=4, fill=true, clip=true})
work(poly{{420,730},{580,730},{610,870},{390,870}}, {hand="body", pile=pile{{"lead white",3},{"zinc white",1}}, coverage=4, fill=true, clip=true})
local ARM = poly{{575,745},{640,700},{660,640},{690,645},{672,725},{598,785}} + poly{{648,585},{702,578},{718,622},{692,652},{652,642}}
work(ARM, {hand="body", pile=SK, coverage=4, fill=true, clip=true})
-- crown: dark with two lit facets
work(poly{{380,330},{500,300},{620,330},{620,440},{380,440}}, {hand="body", pile=pile{{"bone black",2.5},{"ultramarine blue",1}}, coverage=4, fill=true, clip=true})
wait(2880)
work(poly{{380,335},{500,305},{455,415}} + poly{{560,320},{655,365},{590,430}}, {hand="body", pile=pile{{"ultramarine blue",2},{"cobalt blue",1},{"bone black",0.4}}, coverage=3, fill=true, clip=true})
-- bangs, faceted
work(poly{{380,435},{620,435},{625,500},{565,565},{525,480},{470,565},{430,490},{380,560}}, {hand="body", pile=pile{{"bone black",2.5},{"ultramarine blue",1}}, coverage=4, fill=true, clip=true})
local DK = pile{{"bone black",2},{"ultramarine blue",1}}
work(poly{{415,580},{445,560},{475,580},{468,588},{445,573},{422,588}} + poly{{525,580},{555,560},{585,580},{578,588},{555,573},{532,588}}, {hand="detail", pile=DK, coverage=4, fill=true, clip=true})
work(poly{{478,628},{522,628},{514,645},{486,645}}, {hand="detail", pile=pile{{"cadmium red",2},{"rose madder",1}}, coverage=4, fill=true, clip=true})
work(poly{{405,605},{435,605},{435,616},{405,616}} + poly{{565,605},{595,605},{595,616},{565,616}}, {hand="detail", pile=pile{{"lead white",2},{"rose madder",1}}, coverage=3, fill=true, clip=true})
-- warm shadow plane on dress and face (left side away from glow)
work(poly{{420,730},{470,730},{450,870},{390,870}}, {hand="body", pile=pile{{"lead white",2},{"cerulean blue",0.4},{"rose madder",0.2}}, coverage=3, fill=true, clip=true})
-- bubble dots: three amber dots, his reply echoed
work(poly{{680,360},{695,360},{695,375},{680,375}} + poly{{712,360},{727,360},{727,375},{712,375}} + poly{{744,360},{759,360},{759,375},{744,375}}, {hand="detail", pile=pile{{"cadmium yellow",2},{"Mars orange",1}}, coverage=4, fill=true, clip=true})

--@ chunk 6
local HK = pile{{"bone black",2.5},{"ultramarine blue",1}}
work(poly{{390,690},{475,690},{475,730},{420,730},{395,860},{380,860}}, {hand="body", pile=HK, coverage=4, fill=true, clip=true})
work(poly{{525,690},{600,690},{600,740},{580,745},{525,730}}, {hand="body", pile=HK, coverage=4, fill=true, clip=true})
-- table: lit planes, screen glow falling forward
work(poly{{0,1060},{1000,1060},{1000,1250},{0,1250}}, {hand="body", pile=pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"raw sienna",1},{"lead white",0.4}}, coverage=4, fill=true, clip=true, angle=0})
work(poly{{180,1060},{820,1060},{900,1250},{100,1250}}, {hand="body", pile=pile{{"cerulean blue",1},{"lead white",1.5},{"raw sienna",0.5},{"ultramarine blue",0.4}}, coverage=3, fill=true, clip=true, angle=0})
-- power LED and light on bezel lip
work(poly{{860,1010},{880,1010},{880,1030},{860,1030}}, {hand="detail", pile=pile{{"cadmium yellow",2},{"Mars orange",1}}, coverage=4, fill=true, clip=true})
work(poly{{115,975},{885,975},{870,990},{130,990}}, {hand="body", pile=pile{{"cerulean blue",1},{"lead white",1},{"bone black",0.5}}, coverage=3, fill=true, clip=true, angle=0})
