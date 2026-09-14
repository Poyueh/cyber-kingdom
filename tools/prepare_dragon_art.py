"""Cut the approved generated transparent sprite sheet into aligned pixel frames.
Requires Pillow and numpy; run with the bundled workspace Python.
"""
from pathlib import Path
import sys
from PIL import Image
import numpy as np
source=Path(sys.argv[1]);destination=Path(sys.argv[2]);destination.mkdir(parents=True,exist_ok=True)
im=Image.open(source).convert('RGBA');a=np.array(im);mask=a[:,:,3]>20;h,w=mask.shape
labels=np.zeros((h,w),np.int32);components=[];tag=0
for y,x in np.argwhere(mask):
    if labels[y,x]:continue
    tag+=1;queue=[(int(y),int(x))];labels[y,x]=tag;xs=[];ys=[]
    while queue:
        py,px=queue.pop();xs.append(px);ys.append(py)
        for ny,nx in [(py-1,px),(py+1,px),(py,px-1),(py,px+1)]:
            if 0<=ny<h and 0<=nx<w and mask[ny,nx] and labels[ny,nx]==0:
                labels[ny,nx]=tag;queue.append((ny,nx))
    if len(xs)>10000:components.append((tag,(min(xs),min(ys),max(xs)+1,max(ys)+1)))
assert len(components)==4,'Expected exactly four complete dragon silhouettes'
components.sort(key=lambda part:(part[1][1]//(h//2),part[1][0]))
sheet=Image.new('RGBA',(1024,208))
for i,(tag,bounds) in enumerate(components):
    pixels=a.copy();pixels[labels!=tag]=0
    sprite=Image.fromarray(pixels).crop(bounds)
    sprite=sprite.resize((round(sprite.width*.35),round(sprite.height*.35)),Image.Resampling.NEAREST)
    sprite=sprite.quantize(colors=48,method=Image.Quantize.FASTOCTREE,dither=Image.Dither.NONE).convert('RGBA')
    frame=Image.new('RGBA',(256,208));frame.alpha_composite(sprite,(12,204-sprite.height))
    sheet.alpha_composite(frame,(i*256,0))
sheet.save(destination/'dragon.png')
im.save(destination/'source.png')
print(destination/'dragon.png')
