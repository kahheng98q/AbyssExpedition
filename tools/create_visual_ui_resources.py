"""Author VD01 native UI scenes/theme; no gameplay data changes."""
from pathlib import Path
R=Path(__file__).resolve().parents[1]
for name,kind in [('value_bar','Control'),('action_button','Button'),('tooltip','PanelContainer'),('portrait','Control'),('skill_icon','TextureRect'),('status_indicator','Label'),('choice_card','PanelContainer')]:
    p=R/f'scenes/ui/components/{name}.tscn';p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(f'[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://scripts/ui/components/{name}.gd" id="1"]\n[node name="{name}" type="{kind}"]\nscript = ExtResource("1")\n',encoding='utf-8')
def color(h):return 'Color('+', '.join(str(round(int(h[i:i+2],16)/255,6)) for i in (0,2,4))+', 1)'
styles=[]
for name,bg,edge,border in [('panel','191e2e','687c88',1),('screen','191e2e','687c88',1),('normal','191e2e','687c88',1),('hover','252c3d','d6ae68',1),('pressed','252c3d','a5f3e8',1),('focus','191e2e','a5f3e8',2),('disabled','191e2e','3d4c5c',1),('error','191e2e','f37783',1),('pending','191e2e','c99ae8',1),('bar','252c3d','252c3d',0)]:
    s=f'[sub_resource type="StyleBoxFlat" id="{name}"]\nbg_color = {color(bg)}\nborder_color = {color(edge)}\n'
    for d in ('left','top','right','bottom'):s+=f'border_width_{d} = {border}\n'
    if name=='screen':
        for d,n in [('left',20),('right',20),('top',14),('bottom',14)]:s+=f'content_margin_{d} = {n}.0\n'
    elif name not in ('panel','bar','error','pending'):
        for d,n in [('left',8),('right',8),('top',4),('bottom',4)]:s+=f'content_margin_{d} = {n}.0\n'
    styles.append(s)
t=f'[gd_resource type="Theme" load_steps={len(styles)+1} format=3]\n'+''.join(styles)+'[resource]\ndefault_font_size = 12\n'
t+='ScreenPanel/base_type = &"PanelContainer"\nErrorLabel/base_type = &"Label"\nPendingLabel/base_type = &"Label"\n'
t+=f'Label/colors/font_color = {color("e9e6d8")}\nErrorLabel/colors/font_color = {color("f37783")}\nPendingLabel/colors/font_color = {color("c99ae8")}\n'
for state in ('normal','hover','pressed','focus','disabled'):t+=f'Button/styles/{state} = SubResource("{state}")\n'
for state in ('font_color','font_hover_color','font_pressed_color','font_focus_color'):t+=f'Button/colors/{state} = {color("e9e6d8")}\n'
t+=f'Button/colors/font_disabled_color = {color("b8c6d1")}\nPanelContainer/styles/panel = SubResource("panel")\nScreenPanel/styles/panel = SubResource("screen")\nProgressBar/styles/background = SubResource("bar")\nProgressBar/styles/fill = SubResource("bar")\nVBoxContainer/constants/separation = 8\nHBoxContainer/constants/separation = 8\n'
p=R/'data/themes/expedition_theme.tres';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(t,encoding='utf-8')
print('VD01 Theme and 7 native component scenes written')
