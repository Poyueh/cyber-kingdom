from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np
import json
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art/frontier/v002'
SRC=ART/'sources'
SRC.mkdir(parents=True,exist_ok=True)
# Retain native generated alpha; small alpha speckles are removed for crisp nearest-neighbor game rendering.
def clean(im):
    a=np.array(im.convert('RGBA'));a[:,:,3]=np.where(a[:,:,3]<48,0,a[:,:,3]);return Image.fromarray(a)
def main_shape(im):
    a=np.array(im.convert('RGBA'))
    mask=a[:,:,3]>=96
    seen=np.zeros(mask.shape,dtype=bool)
    best=[]
    h,w=mask.shape
    for y,x in zip(*np.where(mask)):
        if seen[y,x]: continue
        todo=[(int(y),int(x))];seen[y,x]=True;component=[]
        while todo:
            cy,cx=todo.pop();component.append((cy,cx))
            for ny,nx in [(cy-1,cx),(cy+1,cx),(cy,cx-1),(cy,cx+1)]:
                if 0<=ny<h and 0<=nx<w and mask[ny,nx] and not seen[ny,nx]:
                    seen[ny,nx]=True;todo.append((ny,nx))
        if len(component)>len(best): best=component
    keep=np.zeros(mask.shape,dtype=bool)
    if best:
        yy,xx=zip(*best);keep[yy,xx]=True
    # Keep a one-pixel antialias fringe belonging to the main silhouette.
    grow=keep.copy()
    grow[1:,:]|=keep[:-1,:];grow[:-1,:]|=keep[1:,:]
    grow[:,1:]|=keep[:,:-1];grow[:,:-1]|=keep[:,1:]
    a[:,:,3]=np.where(grow,a[:,:,3],0)
    return Image.fromarray(a)

def prop(name,box,limit,polygon=None):
    im=clean(Image.open(SRC/'props.png').crop(box))
    if polygon:
        mask=Image.new('L',im.size);ImageDraw.Draw(mask).polygon(polygon,fill=255)
        a=np.array(im);a[:,:,3]=np.minimum(a[:,:,3],np.array(mask));im=Image.fromarray(a)
    im=main_shape(im)
    bounds=im.getbbox();assert bounds,name
    im=im.crop(bounds)
    scale=min(limit[0]/im.width,limit[1]/im.height)
    im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.NEAREST)
    im.save(ART/(name+'.png'))
    return {'source_box':box,'bounds':bounds,'output_size':im.size}
manifest={}
manifest['tree']=prop('tree',(0,0,477,553),(164,184),polygon=[(0,0),(477,0),(477,375),(425,400),(400,553),(0,553)])
manifest['crystal']=prop('crystal',(425,213,766,554),(60,65))
manifest['berries']=prop('berries',(773,283,1150,553),(62,44))
manifest['cache']=prop('cache',(1178,313,1536,553),(52,36))
manifest['outpost']=prop('outpost',(0,557,426,982),(136,132))
manifest['crops']=prop('crops',(441,705,808,975),(138,65))
manifest['stump']=prop('stump',(812,754,1190,987),(55,30))
manifest['deer']=prop('deer',(1195,554,1536,990),(67,80))
im=Image.open(SRC/'background.png').convert('RGBA')
# Align the visible grass top to world y=430; no hidden collision-height mismatch.
im.crop((0,0,1536,802)).resize((960,430),Image.Resampling.NEAREST).save(ART/'woodland.png')
im.crop((0,802,1536,1024)).resize((768,111),Image.Resampling.NEAREST).save(ART/'ground.png')
# Preserve a constant source scale, anchor each foot contact, never stretch individual poses.
sheet=clean(Image.open(SRC/'engineer.png'))
output=Image.new('RGBA',(384,256))
frames=[]
for row in range(4):
    for col in range(6):
        im=main_shape(sheet.crop((col*256,row*256,(col+1)*256,(row+1)*256)))
        a=np.array(im)[:,:,3];ys,xs=np.where(a>96)
        assert len(xs)>500,(row,col)
        bottom=int(ys.max())+1
        by,bx=np.where(a[max(0,bottom-14):bottom,:]>96)
        anchor=float(bx.min()+bx.max())/2
        scaled=im.resize((56,56),Image.Resampling.NEAREST)
        cell=Image.new('RGBA',(64,64))
        cell.alpha_composite(scaled,(round(32-anchor*56/256),round(62-bottom*56/256)))
        output.alpha_composite(cell,(col*64,row*64))
        frames.append({'row':row,'column':col,'source_bottom':bottom,'source_anchor_x':anchor})
output.save(ART/'engineer-atlas.png')
manifest['engineer_frames']=frames
(ART/'recipe.json').write_text(json.dumps(manifest,indent=2))
print('Prepared native-alpha pixel game assets at',ART)

# Building atlas has four columns; transparent components isolate each cell cleanly.
buildings=clean(Image.open(SRC/'buildings.png'))
for index,(name,limit) in enumerate([
    ('hall-1',(145,105)),('hall-2',(154,140)),('hall-3',(166,184)),('workshop',(150,130)),
    ('armory',(150,125)),('forge',(98,122)),('beacon',(68,146)),('wall',(64,96))]):
    col=index%4;row=index//4
    im=main_shape(buildings.crop((col*384,row*512,(col+1)*384,(row+1)*512)))
    im=im.crop(im.getbbox());factor=min(limit[0]/im.width,limit[1]/im.height)
    im.resize((round(im.width*factor),round(im.height*factor)),Image.Resampling.NEAREST).save(ART/(name+'.png'))
# The generated civilian sheet uses a shorter last row; crop authored row bounds before normalizing.
sheet=clean(Image.open(SRC/'citizens.png'))
width,height=sheet.size
row_bounds=[0,306,606,896,height]
output=Image.new('RGBA',(320,256))
for row in range(4):
    for col in range(5):
        left=round(col*width/5);right=round((col+1)*width/5)
        im=main_shape(sheet.crop((left,row_bounds[row],right,row_bounds[row+1])))
        bounds=im.getbbox();assert bounds,(row,col)
        a=np.array(im)[:,:,3];bottom=bounds[3]
        by,bx=np.where(a[max(0,bottom-14):bottom,:]>96)
        anchor=float(bx.min()+bx.max())/2
        factor=46/(bounds[3]-bounds[1])
        scaled=im.resize((round(im.width*factor),round(im.height*factor)),Image.Resampling.NEAREST)
        cell=Image.new('RGBA',(64,64))
        cell.alpha_composite(scaled,(round(32-anchor*factor),round(62-bottom*factor)))
        output.alpha_composite(cell,(col*64,row*64))
output.save(ART/'citizens-atlas.png')

# Match readable resource information: only crystal-bearing trees retain cyan inclusions.
a=np.array(Image.open(ART/'tree.png'))
yy,xx=np.indices(a.shape[:2])
trunk=(xx>a.shape[1]*0.36)&(xx<a.shape[1]*0.7)&(yy>a.shape[0]*0.35)&(yy<a.shape[0]*0.86)
cyan=trunk&(a[:,:,1]>110)&(a[:,:,2]>100)&(a[:,:,1].astype(float)>a[:,:,0]*1.6)&(a[:,:,2].astype(float)>a[:,:,0]*1.5)&(a[:,:,3]>0)
light=a[:,:,1].copy()
for channel,factor in enumerate([0.62,0.43,0.28]): a[:,:,channel]=np.where(cyan,light*factor,a[:,:,channel])
Image.fromarray(a).save(ART/'tree-plain.png')
