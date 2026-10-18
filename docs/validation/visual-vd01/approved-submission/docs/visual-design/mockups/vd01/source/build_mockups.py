"""Original pixel concept masters. Pillow only; never writes runtime assets.
Author: Codex, 2026-10-16. All character/environment/icon geometry authored here.
Windows system fonts are rendered for review only; font binaries are not bundled.
PNG/ORA exports are PROPOSED concepts, not production-ready sprite sheets.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps
import json, math, hashlib, zipfile, io, base64, xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[5]
OUT=Path(__file__).resolve().parents[1]
SRC=OUT/'source'
for folder in ('scales','edges','sprites','layers'): (OUT/folder).mkdir(parents=True,exist_ok=True)
P={'ink':'#10121C','panel':'#191E2E','shadow':'#252C3D','stone':'#3D4C5C','light':'#687C88','tide':'#315763','ivory':'#E9E6D8','mist':'#B8C6D1','gold':'#D6AE68','skin':'#E8B995','skinshade':'#A97468','ally':'#A5F3E8','xp':'#63D3F2','hp':'#79D4AE','warning':'#FFB454','red':'#F37783','abyss':'#49315E','violet':'#8E5EB5','lilac':'#C99AE8'}
def c(key): return P.get(key,key)
def new(size=(640,360),bg='ink'): return Image.new('RGBA',size,c(bg) if bg else (0,0,0,0))
def rect(im,box,fill,outline=None,width=1): ImageDraw.Draw(im).rectangle(box,fill=c(fill) if fill else None,outline=c(outline) if outline else None,width=width)
def poly(im,pts,fill,outline=None): ImageDraw.Draw(im).polygon(pts,fill=c(fill),outline=c(outline) if outline else None)
def line(im,pts,fill,width=1): ImageDraw.Draw(im).line(pts,fill=c(fill),width=width)
def ellipse(im,box,fill=None,outline=None,width=1): ImageDraw.Draw(im).ellipse(box,fill=c(fill) if fill else None,outline=c(outline) if outline else None,width=width)
def font(size=12,bold=False): return ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf' if bold else 'C:/Windows/Fonts/segoeui.ttf',size)
def text(im,xy,s,size=12,fill='ivory',bold=False):
    # Thresholded font masks preserve hard-edged review pixels; no font files copied.
    f=font(size,bold); box=f.getbbox(s); mask=Image.new('L',(max(1,box[2]+2),size+6)); d=ImageDraw.Draw(mask)
    d.text((0,-box[1]),s,font=f,fill=255)
    mask=mask.point(lambda v:255 if v>=115 else 0)
    im.paste(c(fill),tuple(map(int,xy)),mask)
def panel(im,r,accent='light'):
    x,y,w,h=r; rect(im,(x,y,x+w-1,y+h-1),'panel','ink');rect(im,(x+1,y+1,x+w-2,y+h-2),None,accent)
    for a,b in ((x+1,y+1),(x+w-3,y+1),(x+1,y+h-3),(x+w-3,y+h-3)):rect(im,(a,b,a+1,b+1),'gold')
def bar(im,x,y,w,value,role='hp'):
    rect(im,(x,y,x+w-1,y+3),'shadow');rect(im,(x,y,x+max(0,int((w-1)*value)),y+3),role)
def paste(im,other,xy): im.alpha_composite(other,tuple(map(int,xy)))
def save(im,name): im.save(OUT/name)
def hashfile(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def ora(name,layers):
    w,h=layers[0][1].size; root=ET.Element('image',{'w':str(w),'h':str(h),'name':name}); stack=ET.SubElement(root,'stack')
    merged=new((w,h),None)
    for _,im in layers: merged.alpha_composite(im)
    with zipfile.ZipFile(SRC/(name+'.ora'),'w') as z:
        z.writestr('mimetype','image/openraster')
        for i,(label,im) in enumerate(reversed(layers)):
            loc=f'data/layer{i}.png'; b=io.BytesIO();im.save(b,format='PNG');z.writestr(loc,b.getvalue())
            ET.SubElement(stack,'layer',{'name':label,'src':loc,'x':'0','y':'0','opacity':'1.0','visibility':'visible','composite-op':'svg:src-over'})
        z.writestr('stack.xml',ET.tostring(root));b=io.BytesIO();merged.save(b,format='PNG');z.writestr('mergedimage.png',b.getvalue())
        b=io.BytesIO();merged.resize((256,max(1,int(h*256/w))),Image.Resampling.NEAREST).save(b,format='PNG');z.writestr('Thumbnails/thumbnail.png',b.getvalue())
    return merged

def actor(kind,state='idle',frame=0):
    sz=(32,32) if kind=='brinejaw' else (32,48); im=new(sz,None)
    dead=state=='death'; bob=1 if (state=='idle' and frame==1) else 0
    if kind=='aren':
        if dead:
            if frame==0:
                im=actor(kind,'attack',2);rect(im,(8,22,11,26),'tide');line(im,[(7,25),(9,29),(12,30)],'light',2);return im
            if frame==1:
                poly(im,[(7,31),(17,21),(24,27),(26,38),(9,39)],'ink');poly(im,[(8,31),(17,25),(24,31),(24,37),(10,37)],'tide');rect(im,(12,23,20,30),'skin');rect(im,(10,21,20,24),'gold');line(im,[(23,29),(29,37)],'ivory',2)
            else:
                ellipse(im,(5,36,27,41),'ink');rect(im,(6,32+(frame-2)*2,14,38),'ink');rect(im,(7,33+(frame-2)*2,13,37),'skin');rect(im,(15,34,25,39),'tide');rect(im,(15,34,21,35),'gold');line(im,[(23,32),(30,34)],'ivory',2)
            return im
        foot=frame%4 if state=='move' else 0
        # Boots stay in canvas; implied alternating steps do not move world root.
        rect(im,(10,34,14,39),'ink');rect(im,(18,34,22,39),'ink')
        if state=='move':
            rect(im,(10,35-(1 if foot in (0,1) else 0),14,38),'stone');rect(im,(18,35-(1 if foot in (2,3) else 0),22,38),'stone')
            if foot in (0,2):rect(im,((9 if foot==0 else 19),39,(14 if foot==0 else 24),39),'light')
        poly(im,[(7,21+bob),(24,21+bob),(26,32),(22,36),(18,33),(10,35),(5,31)],'ink')
        poly(im,[(8,23+bob),(22,22+bob),(24,31),(19,33),(11,32),(7,31)],'tide')
        poly(im,[(8,23+bob),(15,25+bob),(13,31),(8,32)],'stone')
        rect(im,(12,25+bob,20,33),'shadow');rect(im,(12,25+bob,14,30),'light');rect(im,(11,31,22,33),'gold');rect(im,(16,31,18,33),'ivory')
        # 11px head with a projecting bright forelock.
        poly(im,[(10,9+bob),(19,8+bob),(23,12+bob),(23,19+bob),(20,23+bob),(11,22+bob),(8,17+bob),(8,12+bob)],'ink')
        rect(im,(11,14+bob,21,20+bob),'skin');rect(im,(11,19+bob,13,21+bob),'skinshade');rect(im,(19,15+bob,20,16+bob),'ink')
        poly(im,[(9,11+bob),(13,9+bob),(19,9+bob),(22,12+bob),(21,15+bob),(18,13+bob),(13,14+bob),(11,16+bob),(9,15+bob)],'gold')
        line(im,[(11,11+bob),(17,10+bob),(20,11+bob)],'ivory');rect(im,(8,19+bob,23,23+bob),'ink');rect(im,(9,20+bob,22,22+bob),'gold');rect(im,(13,21+bob,17,23+bob),'ally')
        rect(im,(6,24+bob,10,28+bob),'ink');rect(im,(7,24+bob,9,27+bob),'light')
        # Three actually distinct strike poses. Damage is never driven by them.
        if state=='attack':
            if frame==0: a,b=(24,29),(30,12)
            elif frame==1: a,b=(23,28),(31,28)
            else:a,b=(21,29),(29,36)
        else:a,b=(24,30+bob),(29,15+bob)
        line(im,[a,b],'ink',4);line(im,[a,b],'ivory',2);rect(im,(a[0]-3,a[1]-1,a[0]+3,a[1]+1),'gold');rect(im,(22,28+bob,24,30+bob),'skin')
    elif kind=='thrall':
        if dead:
            if frame==0:
                poly(im,[(9,17),(19,15),(24,36),(10,39),(7,27)],'ink');poly(im,[(10,18),(18,17),(22,35),(11,37)],'abyss');rect(im,(11,17,17,22),'light')
            elif frame==1:poly(im,[(4,34),(15,27),(25,34),(23,39),(6,39)],'ink');poly(im,[(6,34),(15,30),(23,35),(22,38),(7,38)],'abyss');rect(im,(8,32,13,35),'light')
            else:poly(im,[(4,37),(11,33),(18,36),(27,38),(21,40),(7,40)],'ink');line(im,[(6,37),(14,35),(21,38)],'abyss',2)
            return im
        lean=frame if state=='move' else 0
        poly(im,[(9+lean,18),(19+lean,17),(21,23),(23,38),(18,35),(16,39),(13,35),(8,39),(9,28),(6,26)],'ink')
        poly(im,[(10+lean,21),(18+lean,21),(20,28),(21,35),(17,34),(16,37),(13,33),(10,36),(11,27),(8,25)],'abyss')
        line(im,[(12+lean,23),(13,31),(12,34)],'stone',2);line(im,[(18,25),(19,31)],'violet')
        poly(im,[(11+lean,10),(18+lean,12),(20+lean,18),(15+lean,21),(9+lean,17),(9+lean,13)],'ink')
        poly(im,[(11+lean,12),(17+lean,13),(18+lean,17),(14+lean,19),(11+lean,16)],'light');rect(im,(15+lean,14,17+lean,16),'ink')
        line(im,[(8,24),(5,30),(7,32)],'light',2);line(im,[(20,25),(25,29+lean),(24,33)],'light',2)
        if state=='move':rect(im,(10+frame*5,38,12+frame*5,40),'stone')
    else:
        if dead:
            if frame==0:poly(im,[(5,15),(10,10),(22,11),(28,17),(23,24),(8,24)],'ink');poly(im,[(8,16),(12,12),(21,13),(25,17),(22,22),(10,22)],'abyss')
            elif frame==1:poly(im,[(3,20),(9,15),(14,20),(18,15),(28,21),(24,25),(7,25)],'ink');line(im,[(6,21),(10,18),(13,23)],'violet',2);line(im,[(18,22),(20,18),(26,22)],'light',2)
            else:line(im,[(4,24),(11,21),(13,24)],'abyss',3);line(im,[(18,24),(23,22),(27,25)],'stone',2)
            return im
        leg=1+frame%2 if state=='move' else 0
        for side in (-1,1):
            x=16+side*8
            line(im,[(x,17),(16+side*13,21-leg),(16+side*14,24)],'ink',3)
            line(im,[(x,18),(16+side*12,21-leg)],'light')
            poly(im,[(16+side*8,13),(16+side*15,8+leg),(16+side*14,16),(16+side*10,19)],'ink')
            line(im,[(16+side*10,14),(16+side*14,11+leg)],'violet',3)
        poly(im,[(7,12),(12,7),(22,9),(26,15),(23,22),(9,22),(5,17)],'ink')
        poly(im,[(8,13),(13,9),(21,10),(24,15),(21,19),(10,19),(7,16)],'stone')
        line(im,[(10,12),(14,10),(20,11)],'light',2);poly(im,[(12,14),(17,11),(21,15),(18,19),(13,18)],'ink');line(im,[(15,14),(18,14)],'lilac',2)
        rect(im,(10,20,22,21),'abyss');rect(im,(12,21,13,23),'ivory');rect(im,(20,21,21,23),'ivory')
    return im

states={'aren':{'idle':[0,1],'move':[0,1,2,3],'attack':[0,1,2],'hurt':[],'death':[0,1,2,3]},'thrall':{'idle':[0],'move':[0,1],'attack':[],'hurt':[],'death':[0,1,2]},'brinejaw':{'idle':[0],'move':[0,1],'warning':[],'hurt':[],'death':[0,1,2]}}
manifest={'revision':'VD-01-M1','status':'PROPOSED, not production cleanup or integration approval','creator':'Codex / locally authored original pixel geometry','date':'2026-10-16','rights':'Original project concept artwork; no external images copied. System fonts rendered for review, binaries not distributed. Owner acceptance pending.','actors':{},'effects':{},'authored_unique_cells':0,'ceiling':58,'not_gameplay_recordings':True}
for kind,st in states.items():
    w,h=(32,32) if kind=='brinejaw' else (32,48);sheet=new((w*6,h*5),None); entries={}; count=0
    for row,(state,frames) in enumerate(st.items()):
        regions=[]
        for col,fr in enumerate(frames):
            a=actor(kind,state,fr);paste(sheet,a,(col*w,row*h));regions.append([col*w,row*h,w,h]);count+=1
        e={'applicable':True,'regions':regions,'effective_frames':len(frames),'fps':{'idle':6 if kind=='aren' else 4,'move':10 if kind!='thrall' else 8,'attack':15,'warning':1,'hurt':1,'death':8}[state],'loop':state in ('idle','move')}
        if state=='hurt': e.update(reuse_of='idle[0]',effective_frames=1,flash_until='actual hurt_until; can be 2 or 8 ticks')
        if state=='warning':e.update(reuse_of='idle[0]',effective_frames=1,event_origin='deadline-45, only while warning',duration_ticks=45)
        if state=='attack' and kind=='thrall':e.update(applicable=False,reason='contact-only pursuit; no attack event',effective_frames=0)
        if state=='attack' and kind=='aren':e.update(event_origin='attack_until-12',duration_ticks=12)
        if state=='death':e.update(event_origin='valid dead_at; hero/companion lethal hurt_until-8',duration_ticks=30 if kind=='aren' else 24,interruption='results can immediately truncate; never delay cleanup')
        entries[state]=e
    sheet.save(OUT/f'sprites/{kind}.png')
    manifest['actors'][kind]={'canvas':[w,h],'anchor':[16,24 if kind=='brinejaw' else 40],'sheet':f'sprites/{kind}.png','body_bounds':[4,8,24,32] if kind=='aren' else ([5,10,22,31] if kind=='thrall' else [1,7,31,18]),'states':entries,'unique_cells':count,'facing':'one plus horizontal mirror; bodies never rotate'}
    manifest['authored_unique_cells']+=count

def sword(frame=0):
    im=new((64,96),None);d=ImageDraw.Draw(im)
    # Original reach48, total100 degrees; crisp polygonal approximation only.
    for rad,col,thick in ((48,'ally',2),(42 if frame==0 else 39,'xp' if frame==0 else 'mist',2)):
        pts=[(round(8+rad*math.cos(math.radians(t))),round(48+rad*math.sin(math.radians(t)))) for t in range(-50,51,5)]
        line(im,pts,'ink',thick+2);line(im,pts,col,thick)
    if frame==1:line(im,[(51,35),(54,40)],'ivory',2)
    return im
def star(frame=0):
    im=new((16,16),None)
    pts=[(8,0),(10,5),(15,8),(10,10),(8,15),(5,10),(0,8),(5,5)] if frame==0 else [(3,2),(8,5),(13,2),(10,8),(13,13),(8,10),(3,13),(5,8)]
    poly(im,pts,'violet','ink');line(im,[(3,8),(12,8)],'ally',2);line(im,[(8,3),(8,12)],'ally',2);rect(im,(7,7,9,9),'ivory');return im
for kind,fn,w,h in (('sword',sword,64,96),('star',star,16,16)):
    sheet=new((2*w,h),None)
    for f in range(2):paste(sheet,fn(f),(f*w,0))
    save(sheet,f'sprites/{kind}.png');manifest['effects'][kind]={'sheet':f'sprites/{kind}.png','canvas':[w,h],'anchor':[8,48] if kind=='sword' else [8,8],'unique_cells':2,'fps':12,'regions':[[0,0,w,h],[w,0,w,h]],'lifetime':'sword expires=tick+10; removal tick>expires; star retains original projectile lifetime'};manifest['authored_unique_cells']+=2

def tile(index):
    im=new((32,32),'shadow');base=['#293340','#2D3744','#303A47','#28333F'][index%4];rect(im,(0,0,31,31),base)
    if index<8:
        line(im,[(0,0),(31,0)],'#37434F');line(im,[(0,0),(0,31)],'#37434F');line(im,[(0,31),(31,31)],'#202936')
        if index>=4:line(im,[(8,0),(13,10),(10,17),(15,24),(15,31)],'shadow');line(im,[(11,16),(20,20)],'shadow')
    elif index<12:
        for j in range(3):line(im,[(0,8+j*7),(12,10+j*7),(25,8+j*7),(31,9+j*7)],'#31505A')
    else:
        rect(im,(1,2,30,28),'stone','ink');line(im,[(2,3),(29,3)],'light');rect(im,(5,8,26,23),'shadow');line(im,[(6,9),(25,9)],'stone')
    # Sparse, repeatable authored texture, no simulation RNG.
    for k in range(2):
        x=(index*7+k*13)%25+2;y=(index*11+k*9)%25+3;line(im,[(x,y),(x+2,y)],'#3A4550')
    return im
tiles=new((128,128),None)
for i in range(16):paste(tiles,tile(i),((i%4)*32,(i//4)*32))
save(tiles,'sprites/terrain-concept.png')
def prop(index,corruption=100,lit=True):
    im=new((64,96) if index==0 else (32,64),None);w,h=im.size
    ellipse(im,(2,h-12,w-3,h-3),'ink')
    if index==0:
        # Focal shrine: broken gothic gate around an eldritch tide-eye.
        for x in (7,45):
            rect(im,(x,34,x+11,84),'ink');rect(im,(x+2,35,x+9,82),'stone');rect(im,(x+2,36,x+4,80),'light');rect(im,(x-2,78,x+13,86),'shadow','ink');line(im,[(x-1,79),(x+12,79)],'light')
        poly(im,[(5,37),(10,20),(29,4),(36,4),(55,22),(60,38),(48,38),(43,26),(32,16),(20,27),(18,38)],'ink')
        poly(im,[(8,35),(13,22),(30,7),(35,7),(52,24),(57,35),(50,35),(45,24),(32,13),(17,25),(15,35)],'stone')
        line(im,[(10,30),(16,22),(30,9),(33,9)],'light',2)
        poly(im,[(22,45),(30,36),(38,38),(44,50),(40,65),(31,72),(21,62)],'abyss' if corruption else 'shadow','ink')
        if corruption:
            poly(im,[(21,51),(31,44),(43,51),(33,60)],'violet');poly(im,[(25,52),(32,47),(39,52),(32,56)],'lilac' if lit else 'light');rect(im,(31,48,33,56),'ink')
            for s in (-1,1):
                line(im,[(32+s*5,64),(32+s*13,72),(32+s*10,82),(32+s*22,88)],'abyss',3)
                line(im,[(32+s*11,73),(32+s*17,66),(32+s*20,48)],'violet')
        for yy in (85,89):rect(im,(5 if yy==85 else 1,yy,58 if yy==85 else 62,yy+4),'stone','ink');line(im,[(6 if yy==85 else 2,yy+1),(57 if yy==85 else 61,yy+1)],'light')
        if lit:line(im,[(26,79),(38,79)],'lilac' if corruption else 'tide')
    elif index==1:
        rect(im,(7,20,24,55),'ink');rect(im,(8,21,22,54),'stone');rect(im,(8,21,11,54),'light');poly(im,[(6,21),(9,15),(15,17),(18,12),(25,17),(25,22)],'stone','ink');line(im,[(9,18),(14,20)],'light');rect(im,(4,53,27,59),'shadow','ink');line(im,[(5,54),(26,54)],'light')
    elif index==2:
        poly(im,[(1,45),(3,32),(13,17),(25,15),(31,22),(28,28),(18,27),(12,34),(10,46)],'stone','ink');line(im,[(3,39),(8,30),(16,21),(23,19)],'light',2)
    elif index==3:
        poly(im,[(1,50),(8,39),(22,40),(30,48),(28,56),(8,58)],'stone','ink');line(im,[(4,49),(10,43),(21,43)],'light');line(im,[(16,42),(14,50),(20,55)],'shadow')
    elif index==4:
        rect(im,(9,31,24,56),'stone','ink');line(im,[(10,32),(21,32)],'light');ellipse(im,(12,36,21,45),None,'violet' if corruption else 'tide');line(im,[(16,38),(16,43)],'lilac' if corruption else 'light')
    else:
        for x,y in ((8,49),(13,51),(19,48),(23,54)):
            line(im,[(16,58),(x,y),(x-2,y-6)],'tide',2);rect(im,(x,y-5,x+2,y-2),'stone')
        line(im,[(3,58),(11,56)],'mist',2)
    return im
props=new((256,96),None);xx=0
for i in range(6):
    a=prop(i);paste(props,a,(xx,0));xx+=a.width
save(props,'sprites/props-concept.png')

def environment(corruption=100,lit=True,layers=False):
    ground=new();middle=new(bg=None);foreground=new(bg=None)
    for y in range(0,360,32):
        for x in range(0,640,32):
            index=(x//32*3+y//32*7)%13
            paste(ground,tile(4+index%4 if index==3 or index==9 else index%4),(x,y))
    # Coastal shelves stay walkable and flat, not a new room or impassable wall.
    for y in (292,316,340):
        rect(ground,(0,y,639,y+15),'#29434E')
        line(ground,[(0,y),(160,y),(190,y+2),(420,y+2),(450,y),(639,y)],'#3C5962')
    for x in range(0,640,32):paste(middle,tile(12+x//32%4),(x,0))
    for x,y,idx in ((32,74,1),(572,69,1),(84,204,2),(539,252,3),(143,112,4),(493,281,4),(26,263,5),(592,307,5),(85,70,3)):
        paste(middle,prop(idx,corruption,lit),(x,y))
    paste(middle,prop(0,corruption,lit),(440,60))
    for x,y in ((32,67),(592,61),(102,76),(548,271)):
        line(middle,[(x,y),(x+8,y-18),(x+7,y-28)],'tide',2)
    if corruption:
        for x,y in ((460,164),(485,175),(126,180),(552,300)):
            line(middle,[(x-18,y+15),(x,y),(x+3,y-16),(x+13,y-25)],'abyss',3)
            line(middle,[(x,y),(x+16,y+9),(x+23,y+6)],'abyss',2)
            if corruption==100:line(middle,[(x+1,y),(x+2,y-10)],'violet')
    # Foreground reserved to perimeter; none in the active center.
    for x in (0,620):poly(foreground,[(x,328),(x+7,318),(x+14,329),(x+18,359),(x,359)],'shadow','ink')
    if layers:return [('ground / 32px quiet walkable tiles',ground),('midground / shrine and low props',middle),('foreground / perimeter only',foreground)]
    paste(ground,middle,(0,0));paste(ground,foreground,(0,0));return ground

def ownership(im,x,y,companion=False):
    if companion:
        d=ImageDraw.Draw(im)
        for a in range(0,360,90):d.arc((x-13,y-5,x+13,y+5),a,a+50,fill=c('ally'),width=1)
    else:ellipse(im,(x-13,y-5,x+13,y+5),None,'ally')
def place(im,kind,pos,state='idle',frame=0,flip=False,role=None):
    x,y=pos; anchor=24 if kind=='brinejaw' else 40
    ellipse(im,(x-10,y-3,x+10,y+3),'ink')
    if role:ownership(im,x,y,role=='companion')
    a=actor(kind,state,frame)
    if flip:a=ImageOps.mirror(a)
    paste(im,a,(x-16,y-anchor))
def fallback(im,pos,kind):
    x,y=pos;ownership(im,x,y,True)
    rect(im,(x-7,y-20,x+7,y),'ink');rect(im,(x-5,y-12,x+5,y-1),'tide');rect(im,(x-4,y-22,x+4,y-15),'skin')
    if kind=='milo':line(im,[(x+10,y-18),(x+10,y-1)],'lilac',2);line(im,[(x+6,y-13),(x+14,y-13)],'ally',2)
    else:ImageDraw.Draw(im).arc((x+2,y-20,x+16,y),270,90,fill=c('gold'),width=2)
def boss_placeholder(im,x,y):
    poly(im,[(x-19,y),(x-11,y-37),(x+11,y-37),(x+19,y)],'abyss','ink');ellipse(im,(x-6,y-31,x+6,y-19),'hp');rect(im,(x-1,y-29,x+1,y-21),'ink')
    for xx in (-10,0,10):line(im,[(x+xx,y-38),(x+xx,y-45)],'gold',3)
    text(im,(x-29,y+6),'FALLBACK',8,'mist')
def warning(im,x,y,r):
    # Opaque panel-independent edge plus ink outer keyline; no glow fog.
    ellipse(im,(x-r-1,y-r-1,x+r+1,y+r+1),None,'ink',4);ellipse(im,(x-r,y-r,x+r,y+r),None,'warning',2)
    line(im,[(x-4,y),(x+4,y)],'warning');line(im,[(x,y-4),(x,y+4)],'warning')

protocol=json.loads((ROOT/'docs/validation/visual-vd01/recognition-protocol.json').read_text(encoding='utf-8'))
def fixture(condition):
    q=next(q for q in protocol['conditions'] if q['id']==condition)
    if 'copy_positions_from' in q:return dict(fixture(q['copy_positions_from']),**q)
    return q
HUD_RECTS={'hero':[8,8,192,40],'xp':[208,8,184,40],'stats':[400,8,232,40],'boss':[192,56,256,28],'party':[8,306,200,46],'rescue':[216,310,416,38]}
def hud(stress=False,rescue='active',edge=None,corruption=0):
    im=new(bg=None);r={k:list(v) for k,v in HUD_RECTS.items()}
    if edge and ('top' in edge or edge in ('left','right')):
        # P01 candidate: whole upper cluster moves to a quiet middle band.
        for k in ('hero','xp','stats','boss'):r[k][1]+=88
    if edge and 'bottom' in edge:
        r['party'][1]=248;r['rescue'][1]=252
    for k,rr in r.items():
        if k=='boss' and not stress:continue
        if k in ('party','rescue') and not stress:continue
        panel(im,rr,'light' if k!='boss' else 'red')
    x,y,_,_=r['hero'];paste(im,actor('aren').crop((6,8,27,29)),(x+5,y+6));text(im,(x+31,y+5),'Aren · Hero Lv 15',12,'gold',True);text(im,(x+31,y+20),'HP 180 / 250',12);bar(im,x+31,y+34,151,.72)
    x,y,_,_=r['xp'];text(im,(x+8,y+5),'Run Lv 8',12,'xp',True);text(im,(x+8,y+20),'XP 344 / 800',12);bar(im,x+8,y+34,168,.43,'xp')
    x,y,_,_=r['stats'];text(im,(x+8,y+5),'09:00   Coins 120',12,'gold');text(im,(x+8,y+20),f'Abyss {100 if stress else corruption}/100   C · Esc',12,'mist');bar(im,x+8,y+34,215,1 if stress else corruption/100,'violet')
    if stress:
        x,y,_,_=r['boss'];text(im,(x+7,y+4),'TIDEBOUND HIEROPHANT',12,'ivory',True);bar(im,x+7,y+20,242,.68,'red')
        x,y,_,_=r['party'];text(im,(x+8,y+6),'Lia  HP 90 / 160',12,'ally');text(im,(x+8,y+26),'Milo  DOWNED',12,'mist')
        x,y,_,_=r['rescue']
        a,b={'active':('RESCUE  18.0 / 30.0s','Stay in the circle'),'success':('SUCCESS  Sera earned','Save at victory / defeat'),'failed':('RESCUE FAILED','Try next expedition'),'declined':('RESCUE DECLINED','Available next expedition')}[rescue]
        text(im,(x+8,y+5),a,12,'ally' if rescue=='success' else 'ivory',True);text(im,(x+8,y+21),b,12,'mist')
    return im,r
def battle(condition='normal',stress=False,rescue='active',edge=None,gray=False,lit=True):
    q=fixture(condition);bg=environment(q['corruption'],lit);actors=new(bg=None);effects=new(bg=None)
    for p in q['thralls']:place(actors,'thrall',p)
    for p in q['brinejaws']:place(actors,'brinejaw',p)
    for p,k in zip(q['companions'],('lia','milo')):fallback(actors,p,k)
    boss_placeholder(actors,*q['boss'])
    hp=q['hero'];
    if edge:
        hp={'top':(320,8),'bottom':(320,352),'left':(8,208),'right':(632,208),'top-left':(8,8),'top-right':(632,8),'bottom-left':(8,352),'bottom-right':(632,352)}[edge]
    place(actors,'aren',hp,'attack',0,role='hero')
    paste(effects,sword(),(hp[0]-8,hp[1]-48))
    for p in q['friendly_stars']:paste(effects,star(),(p[0]-8,p[1]-8))
    for w in q['warnings']:warning(effects,*w['center'],w['radius'])
    if edge:
        warning(effects,max(20,min(620,hp[0]+(32 if hp[0]<320 else -32))),max(20,min(340,hp[1]+(22 if hp[1]<180 else -22))),18)
        line(effects,[(hp[0]-4,hp[1]),(hp[0]+4,hp[1])],'ivory');line(effects,[(hp[0],hp[1]-4),(hp[0],hp[1]+4)],'ivory')
    ui,r=hud(stress,rescue,edge,q['corruption']);composite=ora('battle-hud' if condition=='normal' and not stress else 'hud-stress' if condition=='max-corruption' and stress and not edge and rescue=='active' else '_scratch',[('environment / original concept',bg),('actors / hero and two enemies; companions-boss fallback',actors),('effects / above decoration',effects),('HUD / 12px essentials',ui)])
    if gray:composite=ImageOps.grayscale(composite).convert('RGBA')
    return composite,r

normal,_=battle();save(normal,'battle-hud.png')
dense,_=battle('dense');save(dense,'combat-dense.png')
maxed,_=battle('max-corruption');save(maxed,'combat-max.png')
for name in ('normal','dense','max-corruption'):
    im,_=battle(name);save(im,f'combat-{name}.png');save(ImageOps.grayscale(im).convert('RGBA'),f'combat-{name}-grayscale.png')
    im,_=battle(name,lit=False);save(im,f'combat-{name}-unlit.png')
    q=fixture(name)
    for lit in (True,False):
        im=environment(q['corruption'],lit)
        for p,k in zip(q['companions'],('lia','milo')):fallback(im,p,k)
        boss_placeholder(im,*q['boss']);u,_=hud(corruption=q['corruption']);paste(im,u,(0,0))
        save(im,f'motion-scene-{name}'+('' if lit else '-unlit')+'.png')
stress,_=battle('max-corruption',True);save(stress,'hud-stress.png')
large=stress.copy()
for box in ((40,12,190,26),(40,28,190,42),(216,28,384,42),(408,12,620,26),(16,312,199,326)):
    rect(large,box,'panel')
text(large,(39,13),'Aren · Hero Lv 30',12,'gold',True);text(large,(39,28),'HP 99999 / 99999',12)
text(large,(216,28),'XP 99999 / 99999',12);text(large,(408,13),'99:59  Coins 999999',12,'gold')
text(large,(16,312),'Long companion… 999/999',12,'ally');save(large,'hud-large-values.png')
for state in ('success','failed','declined'):
    im,_=battle('max-corruption',True,state);save(im,f'hud-{state}.png')
layouts={}
for edge in ('top','bottom','left','right','top-left','top-right','bottom-left','bottom-right'):
    im,r=battle('max-corruption',True,edge=edge);save(im,f'edges/{edge}.png');layouts[edge]={'rectangles':r,'crop':'top body may crop at viewport; white cross marks foot anchor','status':'P01 candidate; not owner accepted'}
(SRC/'_scratch.ora').unlink(missing_ok=True)

def icon(kind):
    im=new((16,16),None)
    if kind==0:line(im,[(4,13),(12,3)],'ink',4);line(im,[(4,13),(12,3)],'ivory',2);line(im,[(3,9),(8,13)],'gold',2)
    elif kind==1:poly(im,[(9,1),(3,9),(7,9),(6,15),(13,6),(9,6)],'gold','ink')
    elif kind==2:poly(im,[(2,4),(5,2),(8,5),(11,2),(14,4),(14,8),(8,14),(2,8)],'hp','ink')
    elif kind==3:poly(im,[(8,1),(14,8),(8,15),(2,8)],'xp','ink');line(im,[(8,4),(11,8),(8,12)],'ivory')
    elif kind==4:ellipse(im,(2,2,14,14),'gold','ink');line(im,[(7,5),(9,5),(9,11),(7,11)],'ivory')
    else:poly(im,[(8,1),(14,5),(11,14),(5,14),(2,5)],'violet','ink');ellipse(im,(5,5,11,10),'lilac');line(im,[(8,6),(8,9)],'ink')
    return im
icons=new((96,16),None)
for i in range(6):paste(icons,icon(i),(16*i,0))
save(icons,'sprites/icons-concept.png')
effects=['+10% starting damage','+10% starting frequency','+10% starting max health.\nHeal 100% of added maximum HP']
names=['Might','Quick Hands','Vitality']
def level(focus=0,state='focus',long=False):
    bg=environment(100);bg=Image.blend(bg,new(bg='ink'),.72);ui=new(bg=None)
    panel(ui,(75,12,490,336));text(ui,(95,26),'A MOMENT OF RESOLVE',20,'gold',True);text(ui,(95,55),'LEVEL UP · World paused · This expedition only',12,'mist')
    for i in range(3):
        x,y,w,h=95,80+i*72,450,64
        accent='ally' if i==focus else 'stone';panel(ui,(x,y,w,h),accent)
        if i==focus:
            rect(ui,(x+3,y+3,x+5,y+h-4),'ally');poly(ui,[(x-12,y+25),(x-6,y+30),(x-12,y+35)],'ally')
        paste(ui,icon(i),(x+12,y+12));text(ui,(x+40,y+8),f'{i+1}  {names[i]}',16,'ivory',True)
        text(ui,(x+320,y+10),['0 taken','0 / 5 taken','0 taken'][i],12,'mist')
        for j,s in enumerate(effects[i].split('\n')):text(ui,(x+40,y+31+j*14),s,12,'mist')
        if i==focus and state!='focus':text(ui,(x+280,y+48),state.upper(),12,'ally')
    text(ui,(95,306),'1 / 2 / 3 · Arrows + Enter · Click',12,'ivory');text(ui,(95,325),'Fresh input required · No reroll / skip',12,'mist')
    if long:
        text(ui,(440,306),'SCROLL',12,'gold');line(ui,[(551,80),(551,290)],'stone');rect(ui,(550,80,552,139),'ally')
    return ora('level-up' if focus==0 and state=='focus' and not long else '_scratch',[('paused environment / illustration',bg),('three actual Resource choices / UI',ui)])
save(level(),'level-up.png')
for f in range(3):save(level(f),f'level-focus-{f}.png')
levelstates=new((1280,720))
for i,(f,s,long) in enumerate(((0,'focus',False),(1,'hover',False),(2,'pressed',False),(2,'pending',True))):paste(levelstates,level(f,s,long),((i%2)*640,(i//2)*360))
save(levelstates,'level-up-states.png');(SRC/'_scratch.ora').unlink(missing_ok=True)

lineup=new();text(lineup,(24,18),'THE EXPEDITION / SILHOUETTE STUDIES',20,'gold',True);text(lineup,(24,47),'PROPOSED · one facing + mirror · original geometry · P03 pending',12,'mist')
for i,kind in enumerate(('aren','thrall','brinejaw')):
    x=24+i*208;w,h=manifest['actors'][kind]['canvas'];anchor=manifest['actors'][kind]['anchor'];a=actor(kind)
    panel(lineup,(x,76,192,258));text(lineup,(x+12,88),['AREN','SALTBOUND','BRINEJAW'][i],16,'ivory',True)
    for j,aa in enumerate((a,ImageOps.mirror(a))):
        paste(lineup,aa.resize((w*2,h*2),Image.Resampling.NEAREST),(x+20+j*80,120))
        ax=x+20+j*80+anchor[0]*2;ay=120+anchor[1]*2;line(lineup,[(ax-4,ay),(ax+4,ay)],'ally');line(lineup,[(ax,ay-3),(ax,ay+3)],'ally')
    silhouette=Image.new('RGBA',a.size,c('ivory'));silhouette.putalpha(a.getchannel('A'));paste(lineup,silhouette,(x+20,232));paste(lineup,ImageOps.mirror(silhouette),(x+68,232))
    text(lineup,(x+12,288),f'{w}x{h} / anchor {anchor[0]},{anchor[1]}',12,'mist');text(lineup,(x+12,309),['Solid ring / gold collar','Torn hem / contact only','Low shell / claw silhouette'][i],12,'mist')
save(lineup,'actor-lineup.png')
lineup_layers=[]
for label,box in [('title',(0,0,640,76)),('Aren / original and mirror',(0,76,230,360)),('Thrall / original and mirror',(230,76,440,360)),('Brinejaw / original and mirror',(440,76,640,360))]:
    layer=new(bg=None);paste(layer,lineup.crop(box),(box[0],box[1]));lineup_layers.append((label,layer))
ora('actor-lineup',lineup_layers)
strip=new((640,440));text(strip,(20,16),'ACTOR STATE ATLAS / PROPOSED',20,'gold',True)
for col,kind in enumerate(states):
    x=20+col*208;text(strip,(x,50),kind.upper(),16,'ally',True);w,h=manifest['actors'][kind]['canvas']
    for row,(state,e) in enumerate(manifest['actors'][kind]['states'].items()):
        y=82+row*68;text(strip,(x,y),state.upper()+(' · N/A' if not e['applicable'] else ' · REUSE' if 'reuse_of' in e else ''),12,'mist')
        if e['regions']:
            for f,_ in enumerate(e['regions']):paste(strip,actor(kind,state,f),(x+f*40,y+17))
        elif e['applicable']:paste(strip,actor(kind),(x,y+17))
text(strip,(20,425),'29 authored cells · hurt reuses idle · Thrall contact-only · no runtime wiring',12,'mist')
save(strip,'actors-strip.png')
ef=new((640,240));text(ef,(20,16),'WEAPONS / EXISTING ATTACKS ONLY',20,'gold',True)
for f in range(2):paste(ef,sword(f),(30+f*100,60));paste(ef,star(f).resize((48,48),Image.Resampling.NEAREST),(320+f*90,80))
text(ef,(20,186),'SWORD · reach48 / 100deg · 2 cells',12,'ally');text(ef,(310,186),'MILO STAR · 2 cells · cyan core',12,'ally');text(ef,(20,214),'PROPOSED · arrows may rotate; actor bodies do not · nonbasic sword retains fallback',12,'mist')
save(ef,'effects-strip.png');effect_layers=[]
for label,box in [('heading',(0,0,640,60)),('sword / two unique cells',(0,60,300,180)),('star / two unique cells',(300,60,640,180)),('rules',(0,180,640,240))]:
    layer=new(ef.size,None);paste(layer,ef.crop(box),(box[0],box[1]));effect_layers.append((label,layer))
ora('effects',effect_layers)
shrine=ora('shrine',environment(100,layers=True));save(shrine,'shrine.png')
save(environment(0),'shrine-0.png');save(environment(100,False),'shrine-unlit.png')
for label,im in environment(100,layers=True):save(im,'layers/'+label.split(' /')[0]+'.png')
ui=new((960,440));text(ui,(24,18),'ONE BORDER / SEVEN STATES',20,'gold',True)
for i,state in enumerate(('DEFAULT','HOVER','FOCUS','PRESSED','DISABLED','ERROR','PENDING')):
    x=24+(i%4)*232;y=64+(i//4)*138;accent={'HOVER':'gold','FOCUS':'ally','PRESSED':'ally','ERROR':'red','PENDING':'lilac'}.get(state,'light');panel(ui,(x,y,212,112),accent);paste(ui,icon(i%6),(x+12,y+15));text(ui,(x+38,y+14),state,16,'ivory',True)
    text(ui,(x+12,y+46),{'DISABLED':'Need 1 promotion item','ERROR':'Save failed · Retry','PENDING':'Saving · no repeat submit'}.get(state,'Action / exact cost visible'),12,'mist')
    text(ui,(x+12,y+76),'Tab / Enter · 12px body',12,'mist')
text(ui,(24,356),'20px  TITLE     16px  Section     12px  Essential value',20,'ivory');text(ui,(24,399),'4 / 8 / 12 spacing · visible disabled reason · pending is not saved',12,'mist');save(ui,'ui-states.png')

edge_positions={'top':[320,8],'bottom':[320,352],'left':[8,208],'right':[632,208],'top-left':[8,8],'top-right':[632,8],'bottom-left':[8,352],'bottom-right':[632,352]}
for k,v in layouts.items():v['hero_foot_anchor_screen']=edge_positions[k]
layout={'revision':'VD-01-M1','viewport':[640,360],'rectangles':HUD_RECTS,'union_area':sum(w*h for x,y,w,h in HUD_RECTS.values()),'ratio':sum(w*h for x,y,w,h in HUD_RECTS.values())/(640*360),'method':'all panel/text/icon/bar regions contained inside listed disjoint rectangles; pixels checked separately','essential_font_px':12,'edge_variants':layouts,'large_value_tests':['Hero Lv30 / HP99999/99999','XP99999/99999','Coins999999','Long companion identity available in details; current catalog labels fit'],'runtime_measurement':'not performed; P01 placement pending approval'}
(OUT/'hud-layout.json').write_text(json.dumps(layout,indent=2),encoding='utf-8')
(OUT/'animation-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
# Scale every board, keeping 1 source pixel an exact 2/3 pixel block.
plates=[]
for name in ('battle-hud','level-up','shrine','combat-dense','hud-stress'):
    im=Image.open(OUT/(name+'.png')).convert('RGBA')
    for s in (1,2,3):
        path=f'scales/{name}-{s}x.png';save(im.resize((640*s,360*s),Image.Resampling.NEAREST),path);plates.append({'path':path,'size':[640*s,360*s],'kind':'PROPOSED integer review plate'})
    plate=new((1371,779),'#000000');paste(plate,im.resize((1280,720),Image.Resampling.NEAREST),(45,29));path=f'scales/{name}-1371x779.png';save(plate,path);plates.append({'path':path,'size':[1371,779],'content':[45,29,1280,720],'margins':[45,46,29,30],'kind':'PROPOSED drawn letterbox, not real-window capture'})
for name in ('actor-lineup','actors-strip','effects-strip','ui-states','level-up-states'):
    im=Image.open(OUT/(name+'.png'))
    for s in (1,2,3):
        path=f'scales/{name}-{s}x.png';save(im.resize((im.width*s,im.height*s),Image.Resampling.NEAREST),path);plates.append({'path':path,'size':[im.width*s,im.height*s],'kind':'PROPOSED design-sheet integer plate; not a game window'})
for edge in layouts:
    im=Image.open(OUT/f'edges/{edge}.png')
    for s in (2,3):
        path=f'scales/edge-{edge}-{s}x.png';save(im.resize((640*s,360*s),Image.Resampling.NEAREST),path);plates.append({'path':path,'size':[640*s,360*s],'kind':'PROPOSED P01 edge plate'})
package={'revision':'VD-01-M1','date':'2026-10-16','status':'PROPOSED review package; G0/G1 pending; no runtime edit','deliveries':['A01','E01','E02','W01','F01','F02','U01','U02'],'support':['shared icons','UI border','portrait crop','seed disclosure proposal'],'scale_plates':plates,'hud_rectangles':HUD_RECTS,'edges':layouts,'recognition_protocol_sha256':hashfile(ROOT/'docs/validation/visual-vd01/recognition-protocol.json'),'production_missing':True,'assets':[]}
for p in sorted(OUT.rglob('*')):
    if p.is_file() and p.name!='package.json':package['assets'].append({'path':p.relative_to(OUT).as_posix(),'sha256':hashfile(p),'status':'PROPOSED / original concept source or export'})
(OUT/'package.json').write_text(json.dumps(package,indent=2),encoding='utf-8')
# JS literal permits file:// use without fetch, modules, or a web server.
embedded={}
for name in [v['sheet'] for v in list(manifest['actors'].values())+list(manifest['effects'].values())]+['combat-'+k+'.png' for k in ('normal','dense','max-corruption')]+['motion-scene-'+k+ext+'.png' for k in ('normal','dense','max-corruption') for ext in ('','-unlit')]+['shrine-0.png','shrine.png','shrine-unlit.png']:
    embedded[name]='data:image/png;base64,'+base64.b64encode((OUT/name).read_bytes()).decode('ascii')
(OUT/'motion-data.js').write_text('window.VD_DATA='+json.dumps({'manifest':manifest,'protocol':protocol,'images':embedded})+';\n',encoding='utf-8')
print(json.dumps({'unique_cells':manifest['authored_unique_cells'],'tile_designs':16,'prop_designs':6,'hud_union':layout['union_area'],'hud_ratio':layout['ratio'],'plate_count':len(plates),'output':str(OUT)}))
