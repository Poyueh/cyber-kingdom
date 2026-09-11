from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/refuge/v001'
def pixel(image,size):
    image=image.convert('RGBA').resize((max(1,size[0]//2),max(1,size[1]//2)),Image.Resampling.LANCZOS)
    alpha=image.getchannel('A').point(lambda a:255 if a>110 else 0)
    rgb=image.convert('RGB').quantize(colors=96,method=Image.Quantize.MEDIANCUT).convert('RGBA')
    rgb.putalpha(alpha)
    return rgb.resize(size,Image.Resampling.NEAREST)
sheet=Image.open(OUT/'sources/props.png').convert('RGBA')
w,h=sheet.size
for name,box,maxsize in [
 ('hall-1',(0,0,w//2,int(h*.55)),(192,182)),
 ('workshop',(w//2,0,w,int(h*.55)),(182,140)),
 ('campfire',(0,int(h*.55),w//2,h),(82,76)),
 ('relay',(w//2,int(h*.55),w,h),(48,98))]:
    im=sheet.crop(box); a=im.getchannel('A').point(lambda v:255 if v>110 else 0); im.putalpha(a)
    im=im.crop(im.getbbox())
    ratio=min(maxsize[0]/im.width,maxsize[1]/im.height)
    size=tuple(max(2,round(n*ratio/2)*2) for n in im.size)
    pixel(im,size).save(OUT/(name+'.png'))
pixel(Image.open(OUT/'sources/background.png'),(960,540)).save(OUT/'skyline.png')
pixel(Image.open(OUT/'sources/forest.png'),(960,320)).save(OUT/'forest.png')
pixel(Image.open(OUT/'sources/ground.png'),(768,112)).crop((0,0,768,111)).save(OUT/'ground.png')
sources={}
for name in ['hall-2','hall-3','armory','forge','beacon','wall','outpost','cache','chest-open','plot','crops']:
    sources[name]='art/cyberpunk/v001/'+name+'.png'
for name in ['tree','tree-plain','crystal','berries','stump','deer','engineer-atlas','citizens-atlas']:
    sources[name]='art/frontier/v002/'+name+'.png'
for name in ['stone','herbs']: sources[name]='art/campaign/v001/'+name+'.png'
sources['plot']='art/campaign/v001/plot.png'
sources['wanderer-idle']='art/ambient/v001/wanderer-idle.png'
sources.update({'knight-attack':'art/characters/knight/processed/attack-v003.png','knight-dash':'art/characters/knight/processed/dash-v001.png','knight-idle':'art/characters/knight/processed/idle-v001.png','knight-run-old':'art/characters/knight/processed/run-v001.png','knight-run':'art/characters/knight/motion-v002/run.png','knight-jump':'art/characters/knight/motion-v002/jump.png'})
for name,source in sources.items():
    im=Image.open(ROOT/source)
    pixel(im,im.size).save(OUT/(name+'.png'))
print('Prepared medium-detail refuge assets; animation UVs and originals retained.')
