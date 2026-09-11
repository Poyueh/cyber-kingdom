"""Prepare original generated prosthetic sprites. Pillow/NumPy only.
Local background cleanup/atlas assembly is authorized by the project owner.
Run from any directory; originals and animation resources are never overwritten.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/characters/prosthetic-v001'
REPORT={}
def clean(im):
    a=np.array(im.convert('RGBA'))
    if im.mode=='RGB':
        # Remove only light neutral background connected to the cell border.
        # Dark armor outlines protect interior steel highlights from this flood.
        rgb=a[:,:,:3].astype(int)
        candidate=((rgb.max(2)-rgb.min(2)<28)&(rgb.min(2)>155))
        mask=Image.fromarray(np.uint8(candidate)*255).copy()
        for point in ([(x,y) for x in range(im.width) for y in [0,im.height-1]]+[(x,y) for y in range(im.height) for x in [0,im.width-1]]):
            if mask.getpixel(point)==255: ImageDraw.floodfill(mask,point,128)
        a[:,:,3]=np.where(np.array(mask)==128,0,255)
    else: a[:,:,3]=np.where(a[:,:,3]>150,255,0)
    a[a[:,:,3]==0,:3]=0
    return Image.fromarray(a)
def cells(name,cols,rows):
    sheet=Image.open(OUT/'sources'/f'{name}.png')
    row_edges=[0,310,588,863,1122] if name=='citizens' else [round(r*sheet.height/rows) for r in range(rows+1)]
    return [clean(sheet.crop((round(c*sheet.width/cols),row_edges[r],
         round((c+1)*sheet.width/cols),row_edges[r+1])))
         for r in range(rows) for c in range(cols)]
def main_component(im, preserve_weapon=False):
    a=np.array(im);mask=a[:,:,3]>0;best=[]
    for y,x in zip(*np.where(mask)):
        if not mask[y,x]: continue
        todo=[(int(x),int(y))];mask[y,x]=False;group=[]
        while todo:
            xx,yy=todo.pop();group.append((xx,yy))
            for nx,ny in [(xx-1,yy),(xx+1,yy),(xx,yy-1),(xx,yy+1)]:
                if 0<=nx<im.width and 0<=ny<im.height and mask[ny,nx]:
                    mask[ny,nx]=False;todo.append((nx,ny))
        if len(group)>len(best):best=group
    keep=np.zeros(mask.shape,dtype=bool)
    for x,y in best:keep[y,x]=True
    if preserve_weapon:
        # Neutral steel can be separated from the outline by the background cleanup.
        # Keep the forward weapon; neighboring-cell fragments occur on the left.
        keep[:,im.width//2:] |= a[:,im.width//2:,3]>0
    a[~keep]=0
    return Image.fromarray(a)
def center_core(im):
    a=np.array(im); rgb=a[:,:,:3].astype(int)
    # Largest cyan component below the head: hip core, not visor or tiny highlights.
    mask=(a[:,:,3]>0)&(rgb[:,:,1]>110)&(rgb[:,:,2]>110)&(rgb[:,:,1]>rgb[:,:,0]*1.5)&(rgb[:,:,2]>rgb[:,:,0]*1.5)
    mask[:int(im.height*.36),:]=False
    mask[int(im.height*.80):,:]=False
    best=[]
    for y,x in zip(*np.where(mask)):
        if not mask[y,x]: continue
        group=[]; todo=[(int(x),int(y))];mask[y,x]=False
        while todo:
            xx,yy=todo.pop();group.append((xx,yy))
            for nx,ny in [(xx-1,yy),(xx+1,yy),(xx,yy-1),(xx,yy+1)]:
                if 0<=nx<im.width and 0<=ny<im.height and mask[ny,nx]:
                    mask[ny,nx]=False;todo.append((nx,ny))
        xs=[p[0] for p in group];ys=[p[1] for p in group]
        ratio=(max(xs)-min(xs)+1)/(max(ys)-min(ys)+1)
        if .55<ratio<1.8 and len(group)>len(best): best=group
    return float(np.median([p[0] for p in best])) if best else im.width*.5
def fit(im,size,scale,anchor=None,baseline=None):
    box=im.getbbox()
    if not box: raise ValueError('Empty generated sprite')
    # Keep shared physical scale across a clip; only align foot baseline and body X.
    x=im.width*.5 if anchor is None else anchor
    foot=box[3]
    cropped=im.crop(box)
    target=(max(1,round(cropped.width*scale)),max(1,round(cropped.height*scale)))
    sprite=cropped.resize(target,Image.Resampling.LANCZOS)
    alpha=sprite.getchannel('A').point(lambda v:255 if v>110 else 0)
    sprite=sprite.convert('RGB').quantize(colors=48,method=Image.Quantize.MEDIANCUT).convert('RGBA')
    sprite.putalpha(alpha)
    result=Image.new('RGBA',size)
    left=round(size[0]/2+(box[0]-x)*scale)
    bottom=(size[1]-3) if baseline is None else baseline
    top=bottom-target[1]
    result.alpha_composite(sprite,(left,top))
    return result
def atlas(name,images,cols):
    w,h=images[0].size
    result=Image.new('RGBA',(w*cols,h*((len(images)+cols-1)//cols)))
    for i,im in enumerate(images): result.alpha_composite(im,((i%cols)*w,(i//cols)*h))
    result.save(OUT/(name+'.png'))
    REPORT[name]={'size':list(result.size),'frames':len(images),'cell':[w,h],
       'occupied_pixels':[int(np.count_nonzero(np.array(im)[:,:,3])) for im in images]}
knight=[main_component(im,True) for im in cells('knight',6,4)]
# 58px body at the existing y=80 foot anchor in each 128x96 frame.
scale=58/float(np.median([im.getbbox()[3]-im.getbbox()[1] for im in knight[:6]]))
poses=[fit(im,(128,96),scale,center_core(im),80) for im in knight]
atlas('knight-idle',[poses[i] for i in [0,1,3,4]],2)
atlas('knight-run',[poses[i] for i in [6,7,8,8,9,10,11,11]],4)
atlas('knight-run-old',poses[6:12],3)
atlas('knight-dash',[poses[i] for i in [12,13,15,17]],2)
# Ascending, near-apex, apex, descending match the existing velocity-selected frames.
atlas('knight-jump',[poses[i] for i in [19,20,20,21]],4)
attack=[main_component(im) for im in cells('attack',4,2)]
attack_scale=58/(attack[0].getbbox()[3]-attack[0].getbbox()[1])
attack_poses=[fit(im,(128,96),attack_scale,center_core(im),80) for im in attack]
atlas('knight-attack',attack_poses,4)
people=cells('citizens',5,4)
# Use common scale; hats and tools may exceed the body but fit within 64px cells.
people_scale=49/float(np.median([people[r*5+1].getbbox()[3]-people[r*5+1].getbbox()[1] for r in range(4)]))
people_frames=[fit(im,(64,64),people_scale,baseline=61) for im in people]
atlas('citizens-atlas',people_frames,5)
engineer=cells('engineer',6,4)
engineer_scale=49/float(np.median([im.getbbox()[3]-im.getbbox()[1] for im in engineer[18:24]]))
atlas('engineer-atlas',[fit(im,(64,64),engineer_scale,baseline=61) for im in engineer],6)
# Authored idle from the new wanderer: upper-body breathing/cloth bend, planted feet.
base=people_frames[0]; idle=[]
for phase in [0,1,1,0,-1,-1]:
    frame=Image.new('RGBA',(64,64))
    for y in range(64):
        shift=phase if 12<=y<37 else 0
        frame.alpha_composite(base.crop((0,y,64,y+1)),(shift,y))
    idle.append(frame)
atlas('wanderer-idle',idle,6)
(OUT/'atlas-report.json').write_text(json.dumps(REPORT,indent=2))
# Readable contact sheet uses actual runtime pixels, enlarged only with nearest filtering.
items=[('Knight',poses[0]),('Dash',poses[13]),('Attack',attack_poses[4])]
items += [(name,people_frames[i]) for i,name in enumerate(['Wanderer','Citizen','Farmer','Hunter','Guard'])]
items += [('Engineer',Image.open(OUT/'engineer-atlas.png').crop((0,192,64,256)))]
board=Image.new('RGB',(600,250),'#182a3b'); draw=ImageDraw.Draw(board)
for i,(name,im) in enumerate(items):
    x=(i%5)*120;y=(i//5)*125
    im.thumbnail((110,95),Image.Resampling.NEAREST)
    board.paste(im,(x+(120-im.width)//2,y+95-im.height),im)
    draw.text((x+8,y+104),name,fill='#c8e5df')
board.resize((1200,500),Image.Resampling.NEAREST).save(OUT/'lineup.png')
print('Prepared',len(REPORT),'atlases; source images, animation UVs, and timings preserved.')

expected={'knight-idle':(256,192),'knight-dash':(256,192),'knight-attack':(512,192),'knight-run':(512,192),'knight-run-old':(384,192),'knight-jump':(512,96),'citizens-atlas':(320,256),'engineer-atlas':(384,256),'wanderer-idle':(384,64)}
for name,size in expected.items():
    assert tuple(REPORT[name]['size'])==size, name+' violates existing atlas dimensions'
    assert min(REPORT[name]['occupied_pixels'])>30, name+' contains an empty frame'
