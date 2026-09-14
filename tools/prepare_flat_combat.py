"""Deterministic sprite preparation; originals retained. Local cleanup authorized by user."""
from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/characters/combo-v005'
src=Image.open(OUT/'source.png').convert('RGBA')
bounds=[0,192,374,560,735,889,1024]
atlas=Image.new('RGBA',(1280,384))
for i in range(24):
 r,c=divmod(i,4);cell=src.crop((c*384,bounds[r],(c+1)*384,bounds[r+1]))
 a=np.array(cell);rgb=a[:,:,:3].astype(int)
 bg=(rgb.max(2)-rgb.min(2)<18)&(rgb.min(2)>155)
 mask=Image.fromarray(bg.astype('uint8')*255).copy()
 for x,y in [(x,y) for x in range(cell.width) for y in [0,cell.height-1]]+[(x,y) for x in [0,cell.width-1] for y in range(cell.height)]:
  if mask.getpixel((x,y))==255:ImageDraw.floodfill(mask,(x,y),128)
 a[np.array(mask)==128]=0
 cell=Image.fromarray(a);box=cell.getbbox();assert box
 # Cyan hip anchors the body independently from sword reach.
 hip=(a[:,:,1]>150)&(a[:,:,2]>140)&(a[:,:,0]<100)&(a[:,:,3]>0)
 hip[:int(cell.height*.3)]=False;hip[:,int(cell.width*.63):]=False
 ys,xs=np.where(hip)
 anchor=float(np.median(xs)) if len(xs)>2 else (box[0]+box[2])/2
 cropped=cell.crop(box);scale=0.42
 cropped=cropped.resize((round(cropped.width*scale),round(cropped.height*scale)),Image.Resampling.NEAREST)
 atlas.alpha_composite(cropped,(i%8*160+80-round((anchor-box[0])*scale),i//8*128+112-cropped.height))
ordered=Image.new('RGBA',atlas.size)
# Anticipation, broad sweep, follow-through and recovery; third cut is a heavy finish.
for dest,source in enumerate([0,1,4,3,2,6,7,0,12,11,10,9,8,8,14,15,8,9,10,11,6,14,15,0]):
 tile=atlas.crop((source%8*160,source//8*128,source%8*160+160,source//8*128+128))
 ordered.alpha_composite(tile,(dest%8*160,dest//8*128))
ordered.save(OUT/'planted.png')
# Existing running drawings: replace just the exposed blade, preserve cape and golden legs.
run=Image.open(ROOT/'art/characters/knight/motion-v002/run.png').convert('RGBA')
for i in range(8):
 x,y=i%4*128,i//4*96
 cell=run.crop((x,y,x+128,y+96));a=np.array(cell)
 # Sword runs down-right from the fist. Only remove steel/cyan pixels on that line.
 for py in range(50,78):
  for px in range(63,96):
   red,green,blue,alpha=map(int,a[py,px])
   if alpha and abs((py-55)-(px-64)*0.66)<7 and green>=red-10 and blue>=red-12:
    a[py,px]=0
 cell=Image.fromarray(a);d=ImageDraw.Draw(cell)
 d.line([(60,54),(26,65)],fill='#182936',width=4)
 d.line([(60,54),(26,65)],fill='#b1d3d9',width=2)
 d.line([(58,54),(27,64)],fill='#e6eeee',width=1)
 d.line([(58,51),(61,57)],fill='#9e8264',width=3)
 run.paste(cell,(x,y))
run.save(OUT/'run.png')
