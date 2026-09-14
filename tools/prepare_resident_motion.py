"""Assemble pixel walk/idle cycles from original generated character art.
The generated study repeats poses: use only the first pose as a costume reference,
then articulate hips/knees/ankles with a planted stance foot. Original retained.
Local cutout/animation processing explicitly authorized by the project owner.
"""
from pathlib import Path
from collections import deque
import math
import json
from PIL import Image, ImageDraw
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/characters/resident-motion-v002'
ROLES=['wanderer','citizen','farmer','hunter','guard','engineer']
CELL=64

def cutout(im):
    a=np.array(im.convert('RGBA'));rgb=a[:,:,:3].astype(int)
    bg=(rgb.max(2)-rgb.min(2)<40)&(rgb.min(2)>150)
    h,w=bg.shape;seen=np.zeros((h,w),bool);q=deque()
    for x in range(w):q.extend([(0,x),(h-1,x)])
    for y in range(h):q.extend([(y,0),(y,w-1)])
    while q:
        y,x=q.popleft()
        if not 0<=x<w or not 0<=y<h or seen[y,x] or not bg[y,x]:continue
        seen[y,x]=True;q.extend([(y-1,x),(y+1,x),(y,x-1),(y,x+1)])
    a[:,:,3]=np.where(seen,0,255)
    # Remove unrelated cell-edge specks, retaining internal silver armor highlights.
    occupied=a[:,:,3]>0;seen[:]=False;best=[]
    for y,x in zip(*np.where(occupied)):
        if seen[y,x]:continue
        q=deque([(y,x)]);component=[]
        while q:
            cy,cx=q.popleft()
            if not 0<=cx<w or not 0<=cy<h or seen[cy,cx] or not occupied[cy,cx]:continue
            seen[cy,cx]=True;component.append((cy,cx));q.extend([(cy-1,cx),(cy+1,cx),(cy,cx-1),(cy,cx+1)])
        if len(component)>len(best):best=component
    a[:,:,3]=0
    for y,x in best:a[y,x,3]=255
    return Image.fromarray(a)

def bases():
    study=Image.open(OUT/'sources/walk-study.png')
    rows=[0,212,408,606,798,1024]
    result=[]
    for row in range(5):
        im=cutout(study.crop((0,rows[row],192,rows[row+1])))
        im=im.crop(im.getbbox());im=im.resize((round(im.width*48/im.height),48),Image.Resampling.NEAREST)
        cell=Image.new('RGBA',(64,64));cell.alpha_composite(im,(32-im.width//2,62-48))
        # Align the pelvis rather than the trailing cloak / carried tool bounding box.
        shift=[-7,0,0,0,0][row]
        aligned=Image.new('RGBA',(64,64));aligned.alpha_composite(cell,(shift,0));result.append(aligned)
    engineer=Image.open(ROOT/'art/characters/prosthetic-v001/engineer-atlas.png').convert('RGBA').crop((0,0,64,64))
    result.append(engineer)
    return result

def segment(draw,a,b,width,color,highlight):
    dx,dy=b[0]-a[0],b[1]-a[1];length=math.hypot(dx,dy)
    nx,ny=-dy/length*width/2,dx/length*width/2
    points=[(round(a[0]+nx),round(a[1]+ny)),(round(b[0]+nx),round(b[1]+ny)),(round(b[0]-nx),round(b[1]-ny)),(round(a[0]-nx),round(a[1]-ny))]
    draw.polygon(points,fill=color)
    draw.line((round(a[0]),round(a[1]),round(b[0]),round(b[1])),fill=highlight,width=2)

def leg(draw,hip,ankle,front,role):
    dx,dy=ankle[0]-hip[0],ankle[1]-hip[1];dist=min(18.7,math.hypot(dx,dy))
    bend=math.sqrt(max(0,9.5**2-(dist/2)**2))
    length=max(1,math.hypot(dx,dy))
    knee=((hip[0]+ankle[0])/2+dy/length*bend,(hip[1]+ankle[1])/2-dx/length*bend)
    outline='#211f22';pants='#49423a' if role!=4 else '#3b4d56'
    light='#75634c' if role!=4 else '#738687'
    if not front:pants='#302c2b';light='#51483d'
    segment(draw,hip,knee,5,outline,pants)
    segment(draw,knee,ankle,4,outline,light if front else pants)
    if front:
        draw.rectangle((round(knee[0])-1,round(knee[1]),round(knee[0])+2,round(knee[1])+2),fill='#879591')
        draw.point((round(knee[0])+1,round(knee[1])),fill='#8dd5c9')
    ax,ay=round(ankle[0]),round(ankle[1])
    draw.polygon([(ax-2,ay-1),(ax+1,ay-1),(ax+2,ay+1),(ax+5,ay+1),(ax+5,ay+3),(ax-2,ay+3)],fill=outline)
    draw.line((ax-1,ay+1,ax+3,ay+2),fill=light,width=1)


def pose(base,role,phase,idle=False):
    im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im)
    bob=round((1-math.cos(phase*4*math.pi))*.6) if not idle else 0
    hip=(32,43+bob)
    for front,offset in [(False,.5),(True,0)]:
        p=(phase+offset)%1
        if idle:foot=(29 if not front else 35,59)
        elif p<.5:foot=(32+8-32*p,59) # planted foot moves backwards with body translation
        else:
            u=(p-.5)*2
            foot=(24+16*u,59-math.sin(math.pi*u)*7)
        leg(d,hip,foot,front,role)
    upper=base.crop((0,0,64,45))
    # Free prosthetic arms counter-swing; carried bows/shields remain supported.
    if role in (1,2,5):
        mask=Image.new('L',upper.size);md=ImageDraw.Draw(mask)
        md.polygon([(18,30),(24,28),(27,33),(26,38),(24,44),(17,44)],fill=255)
        a=np.array(upper);a[:,:,3]=np.where(np.array(mask)>0,0,a[:,:,3]);upper=Image.fromarray(a)

    # Keep breathing above the hips; the feet never float up and down.
    if idle:
        breath=1 if math.sin(phase*2*math.pi)>.5 else 0
        upper=upper.resize((64,45-breath),Image.Resampling.NEAREST)
        im.alpha_composite(upper,(0,breath))
    else:
        # One pixel shoulder lead, then lag: no full-sprite scaling or foot bob.
        lead=round(math.sin(phase*2*math.pi))
        im.alpha_composite(upper,(lead,bob))
    if role in (1,2,5):
        swing=0 if idle else -math.cos(phase*math.tau)
        shoulder=(27+(0 if idle else lead),31+bob)
        elbow=(25+swing*2,36+bob)
        wrist=(25+swing*5,41+bob)
        arm=ImageDraw.Draw(im)
        segment(arm,shoulder,elbow,4,'#28383a','#648785')
        segment(arm,elbow,wrist,4,'#243239','#9caca2')
        arm.point((round(elbow[0]),round(elbow[1])),fill='#89dfcf')
        arm.rectangle((round(wrist[0])-1,round(wrist[1]),round(wrist[0])+1,round(wrist[1])+2),fill='#ac9471')
    return im

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    original=bases();atlas=Image.new('RGBA',(512,768))
    for role,base in enumerate(original):
        for mode in range(2):
            for frame in range(8):atlas.alpha_composite(pose(base,role,frame/8,mode==1),(frame*64,(role*2+mode)*64))
    atlas.save(OUT/'residents.png')
    contact=Image.new('RGBA',(512,384),(20,29,35,255))
    for role in range(6):contact.alpha_composite(atlas.crop((0,role*128,512,role*128+64)),(0,role*64))
    contact.resize((1024,768),Image.Resampling.NEAREST).save(OUT/'sources/walk-contact.png')
    frames=[]
    for f in range(8):
        canvas=Image.new('RGBA',(384,96),(20,29,35,255))
        for role in range(6):canvas.alpha_composite(atlas.crop((f*64,role*128,f*64+64,role*128+64)),(role*64,16))
        frames.append(canvas.resize((1152,288),Image.Resampling.NEAREST).convert('RGB'))
    frames[0].save(OUT/'sources/walk-preview.gif',save_all=True,append_images=frames[1:],duration=100,loop=0)
    (OUT/'recipe.json').write_text(json.dumps({'roles':ROLES,'cell':64,'columns':8,'rows_per_role':['walk','idle'],'stride_pixels':32,'process':'Generated costume study; explicit planted-foot inverse-kinematic legs; nearest-neighbor cutout; original retained. Engineer costume from original prosthetic-v001.','generated_study_limitation':'Repeated poses rejected; only first costume pose used.','preview':'Animation review, not gameplay footage.'},indent=2))
if __name__=='__main__':main()
