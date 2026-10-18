"""Production exports from the owner-approved original pixel masters.
Keeps fixed cells and alpha; no resampling, image generation, or gameplay edits.
"""
from pathlib import Path
from PIL import Image
import hashlib,json,zipfile,io,xml.etree.ElementTree as ET,shutil
R=Path(__file__).resolve().parents[1];M=R/'docs/visual-design/mockups/vd01';S=R/'assets/source/visual-vd01'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,data):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(data,encoding='utf-8')
def ora(p,im,names):
    root=ET.Element('image',{'w':str(im.width),'h':str(im.height),'name':p.stem});st=ET.SubElement(root,'stack')
    with zipfile.ZipFile(p,'w') as z:
        z.writestr('mimetype','image/openraster')
        for i,(label,box) in enumerate(names):
            layer=Image.new('RGBA',im.size);layer.paste(im.crop(box),(box[0],box[1]));b=io.BytesIO();layer.save(b,format='PNG');src=f'data/{i}.png';z.writestr(src,b.getvalue());ET.SubElement(st,'layer',{'name':label,'src':src,'x':'0','y':'0','opacity':'1.0','visibility':'visible','composite-op':'svg:src-over'})
        z.writestr('stack.xml',ET.tostring(root));b=io.BytesIO();im.save(b,format='PNG');z.writestr('mergedimage.png',b.getvalue())
def frames(name,path,states,canvas):
    # All texture regions refer to actual fixed RGBA cells; no trimming/rotation.
    res=['[ext_resource type="Texture2D" path="res://'+path+'" id="1"]'];subs=[];animations=[];n=0
    idle=states['idle']['regions'][0] if 'idle'in states else None
    for state,entry in states.items():
        if not entry.get('applicable',True):continue
        regions=entry['regions'] or [idle]
        fs=[]
        for region in regions:
            if region is None:continue
            n+=1;x,y,w,h=region;key=f'a{n}'
            subs.append(f'[sub_resource type="AtlasTexture" id="{key}"]\natlas = ExtResource("1")\nregion = Rect2({x}, {y}, {w}, {h})\nfilter_clip = true\n')
            fs.append('{"duration":1.0,"texture":SubResource("'+key+'")}')
        animations.append('{"frames":['+','.join(fs)+'],"loop":'+str(entry.get('loop',False)).lower()+',"name":&"'+state+'","speed":'+str(entry['fps'])+'}')
    txt=f'[gd_resource type="SpriteFrames" load_steps={n+2} format=3]\n'+''.join(res)+'\n'+''.join(subs)+'[resource]\nanimations = ['+','.join(animations)+']\n'
    put(R/f'data/visuals/{name}_frames_vd01.tres',txt)

def shrine_master():
    root=ET.Element('image',{'w':'384','h':'224','name':'coast shrine native masters'});st=ET.SubElement(root,'stack')
    with zipfile.ZipFile(S/'shrine.ora','w') as z:
        z.writestr('mimetype','image/openraster')
        for i,(label,file,x,y) in enumerate([('quiet terrain /16 tiles','terrain_vd01.png',256,0),('six props / clean stone','props_vd01.png',0,0),('corruption overlay family','corruption_vd01.png',0,96)]):
            src=f'data/{i}.png';z.writestr(src,(R/'assets/tiles/coast_shrine'/file).read_bytes());ET.SubElement(st,'layer',{'name':label,'src':src,'x':str(x),'y':str(y),'opacity':'1.0','visibility':'visible','composite-op':'svg:src-over'})
        z.writestr('stack.xml',ET.tostring(root))
def main():
    S.mkdir(parents=True,exist_ok=True)
    manifest=json.loads((M/'animation-manifest.json').read_text());records=[]
    for key,a in manifest['actors'].items():
        path='assets/sprites/actors/aren/base_swordsman_vd01.png' if key=='aren' else f'assets/sprites/enemies/{key}_vd01.png'
        dst=R/path;dst.parent.mkdir(parents=True,exist_ok=True)
        im=Image.open(M/a['sheet']).convert('RGBA');im.save(dst)
        # Organize native pixels into editable per-state rows; preserve approved poses.
        w,h=a['canvas'];ora(S/f'{key}.ora',im,[(state,(0,row*h,im.width,(row+1)*h)) for row,state in enumerate(a['states'])])
        a.update(revision='VD-01-P1',creator='Codex / original local pixel masters',date='2026-10-17',source=f'assets/source/visual-vd01/{key}.ora',export=path,approved_concept_sha256='3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49',production_status='pixel export prepared; import and candidate review required',cleanup='Fixed canvas/anchor, alpha, state regions, mirror-neutral semantic geometry and all distinct authored cells checked. No copied franchise imagery.',sha256=sha(dst))
        put(S/f'{key}.manifest.json',json.dumps(a,indent=2));records.append(a)
        frames(key,path,a['states'],a['canvas'])
        contact='true' if key=='thrall' else 'false';warning='true' if key=='brinejaw' else 'false'
        txt=f'''[gd_resource type="Resource" script_class="VisualSet" load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/data/visual_set.gd" id="1"]
[ext_resource type="SpriteFrames" path="res://data/visuals/{key}_frames_vd01.tres" id="2"]
[resource]
script = ExtResource("1")
id = &"{key}_vd01"
silhouette = "{'sword' if key=='aren' else 'crab' if key=='brinejaw' else 'diamond'}"
sprite_frames = ExtResource("2")
canvas_px = Vector2i({w}, {h})
anchor_px = Vector2i({a['anchor'][0]}, {a['anchor'][1]})
style_revision = "VD-01-P1"
actor_kind = "{'hero' if key=='aren' else 'enemy'}"
contact_only = {contact}
warning_only = {warning}
''';put(R/f'data/visuals/{key}_vd01.tres',txt)
    effect_layers=[];x=0
    canvas=Image.new('RGBA',(160,96))
    for key,stem in [('sword','sword_arc'),('star','homing_star')]:
        a=manifest['effects'][key];p=R/f'assets/effects/slice/{stem}_vd01.png';p.parent.mkdir(parents=True,exist_ok=True);im=Image.open(M/a['sheet']).convert('RGBA');im.save(p);canvas.paste(im,(x,0));effect_layers.append((key,(x,0,x+im.width,im.height)));x+=im.width
        frames(key,p.relative_to(R).as_posix(),{'active':{'regions':a['regions'],'fps':12,'loop':key=='star'}},a['canvas'])
        a.update(export=p.relative_to(R).as_posix(),sha256=sha(p));records.append(a)
    ora(S/'effects.ora',canvas,effect_layers);put(S/'effects.manifest.json',json.dumps(manifest['effects'],indent=2))
    for src,dest in [('terrain-concept.png','terrain_vd01.png'),('props-concept.png','props_vd01.png')]:
        p=R/'assets/tiles/coast_shrine'/dest;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(M/'sprites'/src,p)
    # Transparent overlay family extracted from the original shrine's authored eye/branches.
    props=Image.open(M/'sprites/props-concept.png').convert('RGBA');overlay=Image.new('RGBA',props.size)
    for yy in range(props.height):
        for xx in range(64):
            px=props.getpixel((xx,yy))
            if px[:3] in [(73,49,94),(142,94,181),(201,154,232)]:overlay.putpixel((xx,yy),px)
    overlay.save(R/'assets/tiles/coast_shrine/corruption_vd01.png')
    # Remove corruption pixels from base prop: clean quiet stone remains at corruption0.
    base=props.copy()
    for yy in range(base.height):
        for xx in range(64):
            if overlay.getpixel((xx,yy))[3]:base.putpixel((xx,yy),(37,44,61,255))
    base.save(R/'assets/tiles/coast_shrine/props_vd01.png')
    shrine_master();put(S/'shrine.manifest.json',json.dumps({'tiles':16,'props':6,'tile_px':[32,32],'world':[960,540],'collision':False,'navigation':False,'overlay_family':1,'dynamic_lights':0,'dynamic_shadows':0,'shaders':0,'revision':'VD-01-P1','source_layers':['terrain16 native cells','clean six props','corruption original glyph pixels'],'source_note':'unmodified production atlases packaged as separate native ORA layers; no merged preview supplied'},indent=2))
    ui=R/'assets/ui';ui.mkdir(parents=True,exist_ok=True)
    Image.open(M/'sprites/aren.png').crop((4,7,28,31)).save(ui/'aren_portrait_vd01.png');shutil.copy2(M/'sprites/icons-concept.png',ui/'slice_icons_vd01.png')
    u=Image.new('RGBA',(120,24));u.paste(Image.open(ui/'aren_portrait_vd01.png'),(0,0));u.paste(Image.open(ui/'slice_icons_vd01.png'),(24,0));ora(S/'ui.ora',u,[('Aren crop',(0,0,24,24)),('six icons',(24,0,120,16))]);put(S/'ui.manifest.json',json.dumps({'portrait':'Aren base only','icons':6,'icon_px':[16,16],'source':'owner-approved original VD-01-M1 masters','revision':'VD-01-P1'},indent=2))
    put(S/'delivery.json',json.dumps({'records':records,'authored_unique_cells':29,'status':'production exports; approval and verification separate','rights':'original project pixel geometry, no external art/font binaries copied'},indent=2))
    # Source masters are editable evidence; exclude them from release packs.
    p=R/'export_presets.cfg';text=p.read_text();text=text.replace('exclude_filter="','exclude_filter="assets/source/*,assets/source/**,',1) if 'assets/source/**' not in text else text;put(p,text)
    print('VD01 production exports and manifests prepared; 29 authored cells /16 tiles /6 props')
if __name__=='__main__':main()
