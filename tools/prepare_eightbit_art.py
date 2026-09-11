"""Build the 8-bit style study: fixed 16-color palette, 4x integer pixels.
Pillow/NumPy; local processing approved by the project owner. Original art retained.
"""
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/eightbit/v001'
COLORS=['080c1c','142040','263858','465878','7888a0','c2d4d8','12606c','20b0bc','60e0d0','b83888','e870a0','d88038','f8d878','488858','785848','c09870']
PALETTE=np.array([tuple(bytes.fromhex(c)) for c in COLORS],dtype=np.int32)

def flat(image, size):
    image=image.convert('RGBA').resize(size,Image.Resampling.NEAREST)
    data=np.array(image);rgb=data[:,:,:3].astype(np.int32)
    nearest=((rgb[:,:,None,:]-PALETTE[None,None,:,:])**2).sum(axis=3).argmin(axis=2)
    data[:,:,:3]=PALETTE[nearest];data[:,:,3]=np.where(data[:,:,3]>100,255,0)
    return Image.fromarray(data)

def coarse(image):
    return flat(image,(max(1,image.width//4),max(1,image.height//4))).resize(image.size,Image.Resampling.NEAREST)

sheet=Image.open(OUT/'sources/sprites.png').convert('RGBA')
spec=[('hall-1',168,144),('hall-2',192,160),('hall-3',212,184),('workshop',152,144),('armory',156,144),('forge',148,144),('beacon',76,124),('wall',148,100),('outpost',128,128),('campfire',80,76),('plot',80,92),('crops',108,76),('relay',56,92),('cache',56,48),('chest-open',56,60),('tree',108,168)]
# The generated cell rows are separated by transparent bands at 320, 640, 936.
rows=[(0,320),(321,640),(641,936),(937,1284)]
for i,(name,width,max_height) in enumerate(spec):
    x0=round(i%4*sheet.width/4);x1=round((i%4+1)*sheet.width/4);y0,y1=rows[i//4]
    sprite=sheet.crop((x0,y0,x1,y1))
    a=np.array(sprite);a[:,:,3]=np.where(a[:,:,3]>100,255,0);sprite=Image.fromarray(a)
    sprite=sprite.crop(sprite.getbbox())
    ratio=min(width/sprite.width,max_height/sprite.height)
    size=(max(1,round(sprite.width*ratio/4)),max(1,round(sprite.height*ratio/4)))
    sprite=flat(sprite,size).resize((size[0]*4,size[1]*4),Image.Resampling.NEAREST)
    sprite.save(OUT/(name+'.png'))
    if name=='tree': sprite.save(OUT/'tree-plain.png')

flat(Image.open(OUT/'sources/skyline.png'),(240,108)).resize((960,432),Image.Resampling.NEAREST).save(OUT/'skyline.png')
# Source existing geometry/animation remains unchanged; reduce its texture detail only.
for name in ['crystal','berries','stump','deer','engineer-atlas','citizens-atlas']:
    source=ROOT/('art/frontier/v002/'+name+'.png')
    coarse(Image.open(source)).save(OUT/(name+'.png'))
for name in ['stone','herbs']:
    coarse(Image.open(ROOT/('art/campaign/v001/'+name+'.png'))).save(OUT/(name+'.png'))
coarse(Image.open(ROOT/'art/ambient/v001/wanderer-idle.png')).save(OUT/'wanderer-idle.png')
# Atlas cell widths/heights (64, 96, 128) divide by four; frame origins remain exact.
knight_sources={
    'knight-attack':'art/characters/knight/processed/attack-v003.png',
    'knight-dash':'art/characters/knight/processed/dash-v001.png',
    'knight-idle':'art/characters/knight/processed/idle-v001.png',
    'knight-run-old':'art/characters/knight/processed/run-v001.png',
    'knight-run':'art/characters/knight/motion-v002/run.png',
    'knight-jump':'art/characters/knight/motion-v002/jump.png'}
for name,source in knight_sources.items(): coarse(Image.open(ROOT/source)).save(OUT/(name+'.png'))
print('Prepared 8-bit scene study: 16 colors, enlarged pixels; original atlas dimensions retained.')

ground=Image.open(OUT/'sources/ground.png').convert('RGBA')
a=np.array(ground).astype(np.int32)
rail=(a[:,:,1]>a[:,:,0]*1.4)&(a[:,:,2]>80)
top=next(y for y in range(ground.height) if rail[y].mean()>0.5)
flat(ground.crop((0,top,ground.width,ground.height)),(192,28)).resize((768,112),Image.Resampling.NEAREST).crop((0,0,768,111)).save(OUT/'ground.png')
