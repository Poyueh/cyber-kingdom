"""Retained imagegen sources -> pixel-aligned runtime theme. Requires Pillow/NumPy.
Local cropping, alpha cleanup and image assembly authorized by the project owner.
"""
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]/'art/cyberpunk/v001'

def clean(image):
    data=np.array(image.convert('RGBA'))
    alpha=data[:,:,3].copy()
    hologram=(data[:,:,0]>150)&(data[:,:,2]>140)&(data[:,:,1]<150)&(alpha>2)
    data[:,:,3]=np.where(alpha>160,255,0)
    data[:,:,3]=np.where(hologram,np.maximum(data[:,:,3],np.minimum(alpha.astype(int)*6,190)),data[:,:,3])
    return Image.fromarray(data)

def save_sprite(sheet, name, box, width):
    sprite=clean(sheet.crop(box))
    sprite=sprite.crop(sprite.getbbox())
    sprite=sprite.resize((width,round(sprite.height*width/sprite.width)),Image.Resampling.NEAREST)
    sprite.save(ROOT/(name+'.png'))
    data=np.array(sprite)
    cyan=(data[:,:,1]>150)&(data[:,:,2]>135)&(data[:,:,0]<data[:,:,1]*0.85)
    magenta=(data[:,:,0]>160)&(data[:,:,2]>140)&(data[:,:,1]<130)
    data[:,:,3]=np.where(cyan|magenta,data[:,:,3],0)
    data[:,:,:3]=np.minimum(data[:,:,:3].astype(int)+55,255)
    Image.fromarray(data).save(ROOT/(name+'-emission.png'))

buildings=Image.open(ROOT/'sources/buildings.png')
rows=[(0,375),(376,675),(676,1024)]
specs=[('hall-1',168),('hall-2',192),('hall-3',210),('workshop',152),('armory',156),('forge',148),('beacon',78),('wall',148),('outpost',128)]
for index,(name,width) in enumerate(specs):
    x=(index%3)*512;y1,y2=rows[index//3]
    save_sprite(buildings,name,(x,y1,x+512,y2),width)
props=Image.open(ROOT/'sources/props.png')
for name,box,width in [
    ('campfire',(0,0,510,474),80),('plot',(512,0,1040,500),80),
    ('crops',(1040,0,1536,500),110),('relay',(0,474,500,1024),58),
    ('cache',(512,520,1010,1024),54),('chest-open',(1040,510,1536,1024),54)]:
    save_sprite(props,name,box,width)

# Keep the playable floor at row 0; exclude alpha margins above the generated strip.
ground=Image.open(ROOT/'sources/ground.png').convert('RGBA')
a=np.array(ground)[:,:,3]
top=next(y for y in range(270,310) if np.mean(a[y]>160)>0.998)
ground=ground.crop((0,top,ground.width,522)).resize((768,111),Image.Resampling.NEAREST)
base=Image.new('RGBA',ground.size,(8,14,20,255));base.alpha_composite(ground)
base.save(ROOT/'ground.png')
sky=ROOT/'sources/skyline.png'
if not sky.exists(): sky=ROOT/'sources/skyline-study.png'
Image.open(sky).convert('RGB').resize((960,430),Image.Resampling.NEAREST).save(ROOT/'skyline.png')
print('Prepared 15 sprites, emission layers, ground and skyline.')
