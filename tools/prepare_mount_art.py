"""Preserve generated source, remove its neutral checkerboard, align six mounted poses."""
from pathlib import Path
import sys
import numpy as np
from PIL import Image
source=Path(sys.argv[1]);dest=Path(sys.argv[2]);dest.mkdir(parents=True,exist_ok=True)
im=Image.open(source).convert('RGBA');a=np.array(im);rgb=a[:,:,:3].astype(int)
# The generated background is opaque neutral white/grey; the hero has coloured outlines.
background=(rgb.max(2)-rgb.min(2)<=9)&(rgb.min(2)>=195)
a[background,3]=0
mask=a[:,:,3]>20;h,w=mask.shape;labels=np.zeros((h,w),np.int32);parts=[];tag=0
for y,x in np.argwhere(mask):
 if labels[y,x]:continue
 tag+=1;stack=[(int(y),int(x))];labels[y,x]=tag;xs=[];ys=[]
 while stack:
  yy,xx=stack.pop();xs.append(xx);ys.append(yy)
  for ny,nx in [(yy-1,xx),(yy+1,xx),(yy,xx-1),(yy,xx+1)]:
   if 0<=ny<h and 0<=nx<w and mask[ny,nx] and not labels[ny,nx]:labels[ny,nx]=tag;stack.append((ny,nx))
 if len(xs)>10000:parts.append((tag,(min(xs),min(ys),max(xs)+1,max(ys)+1)))
assert len(parts)==6,parts
parts.sort(key=lambda v:(v[1][1]//(h//2),v[1][0]))
sheet=Image.new('RGBA',(960,128))
for i,(tag,box) in enumerate(parts):
 pixels=a.copy();pixels[labels!=tag]=0
 sprite=Image.fromarray(pixels).crop(box)
 sprite=sprite.resize((round(sprite.width*.23),round(sprite.height*.23)),Image.Resampling.NEAREST)
 sprite=sprite.quantize(colors=48,method=Image.Quantize.FASTOCTREE,dither=Image.Dither.NONE).convert('RGBA')
 sheet.alpha_composite(sprite,(i*160+(160-sprite.width)//2,122-sprite.height))
sheet.save(dest/'mounted.png');im.save(dest/'source.png');print(parts)
