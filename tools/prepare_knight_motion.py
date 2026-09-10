from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]
folder=root/'art/characters/knight/motion-v002'
im=Image.open(folder/'sources/motion.png').convert('RGBA')
w,h=im.size
print('Source',im.size,'alpha',im.getchannel('A').getextrema())
frames=[]
for i in range(12):
    col,row=i%4,i//4
    crop=im.crop((col*w//4,row*h//3,(col+1)*w//4,(row+1)*h//3))
    a=crop.getchannel('A').point(lambda x: 255 if x>=64 else 0)
    crop.putalpha(a)
    crop=crop.crop(a.getbbox())
    frames.append(crop)
# One common scale preserves crouched jump silhouettes and anatomy.
scale=54/max(c.height for c in frames[:8])
for label,start,count in [('run',0,8),('jump',8,4)]:
    atlas=Image.new('RGBA',(128*4,96*((count+3)//4)))
    for index,cell in enumerate(frames[start:start+count]):
        cell=cell.resize((round(cell.width*scale),round(cell.height*scale)),Image.Resampling.NEAREST)
        # Centre the torso, not the long trailing cape, under the actor origin.
        anchor=round(cell.width*0.65)
        baseline=78 if label=='run' and index in [3,7] else 80
        atlas.alpha_composite(cell,(index%4*128+64-anchor,index//4*96+baseline-cell.height))
    atlas.save(folder/(label+'.png'))
text='[gd_resource type="SpriteFrames" load_steps=15 format=3]\n'
for label in ['run','jump']: text+=f'[ext_resource type="Texture2D" path="res://art/characters/knight/motion-v002/{label}.png" id="{label}"]\n'
for label,count in [('run',8),('jump',4)]:
    for i in range(count): text+=f'[sub_resource type="AtlasTexture" id="{label}_{i}"]\natlas = ExtResource("{label}")\nregion = Rect2({i%4*128}, {i//4*96}, 128, 96)\nfilter_clip = true\n'
text+='[resource]\nanimations = [\n'
for label,count in [('run',8),('jump',4)]:
    text+='{"name": &"'+label+'", "loop": true, "speed": 12.0, "frames": ['+', '.join('{"duration": 1.0, "texture": SubResource("'+label+'_'+str(i)+'")}' for i in range(count))+']},\n'
text+=']\n'
(root/'data/knight_motion_frames.tres').write_text(text)
