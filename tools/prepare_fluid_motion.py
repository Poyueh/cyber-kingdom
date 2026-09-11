"""Prepare 8 unique running poses and offline moving-attack combinations.
Uses Pillow/NumPy and the owner's existing authorization for local art editing.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/characters/fluid-v001'
def clean(im):
    a=np.array(im.convert('RGBA'))
    if im.mode=='RGB':
        rgb=a[:,:,:3].astype(int)
        candidate=(rgb.max(2)-rgb.min(2)<28)&(rgb.min(2)>155)
        mask=Image.fromarray(np.uint8(candidate)*255).copy()
        for p in ([(x,y) for x in range(im.width) for y in [0,im.height-1]]+[(x,y) for y in range(im.height) for x in [0,im.width-1]]):
            if mask.getpixel(p)==255: ImageDraw.floodfill(mask,p,128)
        a[:,:,3]=np.where(np.array(mask)==128,0,255)
    else: a[:,:,3]=np.where(a[:,:,3]>150,255,0)
    return Image.fromarray(a)
sheet=Image.open(OUT/'sources/run.png')
cells=[clean(sheet.crop((round(c*sheet.width/4),round(r*sheet.height/2),round((c+1)*sheet.width/4),round((r+1)*sheet.height/2)))) for r in range(2) for c in range(4)]
scale=58/np.median([im.getbbox()[3]-im.getbbox()[1] for im in cells])
run=[]
for im in cells:
    a=np.array(im); rgb=a[:,:,:3].astype(int)
    core=(a[:,:,3]>0)&(rgb[:,:,1]>130)&(rgb[:,:,2]>130)&(rgb[:,:,1]>rgb[:,:,0]*1.5)
    core[:int(im.height*.42)]=False;core[int(im.height*.75):]=False
    core[:,:int(im.width*.3)]=False;core[:,int(im.width*.68):]=False
    ys,xs=np.where(core)
    anchor=float(np.median(xs))
    box=im.getbbox();sprite=im.crop(box)
    size=tuple(max(1,round(n*scale)) for n in sprite.size)
    sprite=sprite.resize(size,Image.Resampling.LANCZOS)
    alpha=sprite.getchannel('A').point(lambda a:255 if a>110 else 0)
    sprite=sprite.convert('RGB').quantize(colors=48).convert('RGBA');sprite.putalpha(alpha)
    frame=Image.new('RGBA',(128,96))
    frame.alpha_composite(sprite,(round(64+(box[0]-anchor)*scale),80-size[1]))
    run.append(frame)
atlas=Image.new('RGBA',(512,192))
for i,im in enumerate(run): atlas.alpha_composite(im,((i%4)*128,(i//4)*96))
atlas.save(OUT/'run.png')
# Re-align the strike source using only the torso zone, never the large cyan slash.
source=Image.open(ROOT/'art/characters/prosthetic-v001/sources/attack.png')
attack=Image.new('RGBA',(512,192))
for i in range(8):
    im=clean(source.crop((round(i%4*source.width/4),round(i//4*source.height/2),round((i%4+1)*source.width/4),round((i//4+1)*source.height/2))))
    a=np.array(im);rgb=a[:,:,:3].astype(int)
    core=(a[:,:,3]>0)&(rgb[:,:,1]>130)&(rgb[:,:,2]>130)&(rgb[:,:,1]>rgb[:,:,0]*1.5)
    core[:int(im.height*.4)]=False;core[int(im.height*.8):]=False
    core[:,:int(im.width*.28)]=False;core[:,int(im.width*.6):]=False
    ys,xs=np.where(core)
    anchor=float(np.median(xs))
    # Keep the connected body/sword; neighboring-cell light fragments are separate.
    mask=Image.fromarray(np.uint8(a[:,:,3]>0)*255).copy()
    seed=(int(xs[len(xs)//2]),int(ys[len(ys)//2]))
    ImageDraw.floodfill(mask,seed,128)
    a[np.array(mask)!=128]=0
    im=Image.fromarray(a);box=im.getbbox()
    if i==0: attack_scale=58/(box[3]-box[1])
    sprite=im.crop(box)
    size=tuple(max(1,round(n*attack_scale)) for n in sprite.size)
    sprite=sprite.resize(size,Image.Resampling.LANCZOS)
    alpha=sprite.getchannel('A').point(lambda a:255 if a>110 else 0)
    sprite=sprite.convert('RGB').quantize(colors=48).convert('RGBA');sprite.putalpha(alpha)
    frame=Image.new('RGBA',(128,96))
    frame.alpha_composite(sprite,(round(64+(box[0]-anchor)*attack_scale),80-size[1]))
    attack.alpha_composite(frame,((i%4)*128,(i//4)*96))
attack.save(OUT/'attack.png')
combined=Image.new('RGBA',(1024,768))
for gait,legs in enumerate(run):
    lower=legs.copy()
    ImageDraw.Draw(lower).rectangle((0,0,127,54),fill=(0,0,0,0))
    # Remove the running sword so only the actual attack blade remains.
    ImageDraw.Draw(lower).rectangle((82,55,127,67),fill=(0,0,0,0))
    for strike in range(8):
        upper=attack.crop(((strike%4)*128,(strike//4)*96,(strike%4+1)*128,(strike//4+1)*96))
        a=np.array(upper)
        yy,xx=np.indices(a.shape[:2])
        weapon=(xx>=85)&(yy<=xx*.52+18) if strike in [0,3,5,6,7] else np.zeros(xx.shape,dtype=bool)
        a[(yy>=55)&~weapon]=0
        upper=Image.fromarray(a)
        frame=lower.copy();frame.alpha_composite(upper)
        combined.alpha_composite(frame,(strike*128,gait*96))
combined.save(OUT/'moving-attack.png')
assert len({im.tobytes() for im in run})==8
print('8 distinct run poses; 64 precomposed moving strikes; original combat frames retained.')
