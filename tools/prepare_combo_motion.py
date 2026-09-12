"""Prepare independent hand-drawn cuts; retained source and deterministic local cleanup."""
from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'art/characters/combo-v002'
CELL = (160, 128)
BASELINE = 112
def clean(image):
    a = np.array(image.convert('RGBA'))
    rgb = a[:, :, :3].astype(int)
    candidate = (rgb.max(2)-rgb.min(2)<24)&(rgb.min(2)>170)
    mask = Image.fromarray(np.uint8(candidate)*255).copy()
    for x,y in [(x,y) for x in range(image.width) for y in [0,image.height-1]]+[(x,y) for y in range(image.height) for x in [0,image.width-1]]:
        if mask.getpixel((x,y))==255: ImageDraw.floodfill(mask,(x,y),128)
    a[np.array(mask)==128] = 0
    return Image.fromarray(a)
def core(image):
    a=np.array(image);r,g,b=[a[:,:,i].astype(int) for i in range(3)]
    mask=(a[:,:,3]>0)&(g>125)&(b>135)&(r<g*.65)
    mask[:int(image.height*.35)]=False
    mask[:, :int(image.width*.27)]=False
    mask[:, int(image.width*.7):]=False
    y,x=np.where(mask)
    assert len(x)>3, 'missing hip reference'
    return (float(np.median(x)),float(np.median(y)))
sheet=Image.open(OUT/'sources/combo.png')
cells=[clean(sheet.crop((i%4*256,i//4*256,i%4*256+(280 if i in [4,20] else 256),i//4*256+256))) for i in range(24)]
# Adjacent sword-tip fragments can cross the source grid; retain the body component.
for i,im in enumerate(cells):
    cx,cy=core(im)
    mask=Image.fromarray(np.uint8(np.array(im)[:,:,3]>0)*255).copy()
    ImageDraw.floodfill(mask,(round(cx),round(cy)),128)
    a=np.array(im);a[np.array(mask)!=128]=0
    cells[i]=Image.fromarray(a)
scale=58/(cells[0].getbbox()[3]-cells[0].getbbox()[1])
palette_source=Image.new('RGB',(256*4,256*6),(15,22,34))
for i,im in enumerate(cells): palette_source.paste(im,(i%4*256,i//4*256),im)
palette=palette_source.quantize(colors=40)
poses=[]
hips=[]
weapon_masks=[]
# Hilt and tip landmarks in each source cell preserve the low sword separately from legs.
low_swords={0:((148,191),(225,230)),5:((148,176),(245,218)),6:((160,187),(252,227)),
7:((130,179),(223,225)),8:((165,182),(252,220)),9:((135,178),(228,220)),
18:((156,158),(241,207)),19:((135,172),(227,211)),20:((170,169),(274,206)),
21:((150,161),(245,202)),22:((148,153),(237,195)),23:((124,160),(221,199))}
for source_index,im in enumerate(cells):
    cx,cy=core(im);box=im.getbbox()
    size=tuple(round(n*scale) for n in im.crop(box).size)
    sprite=im.crop(box).resize(size,Image.Resampling.LANCZOS)
    alpha=sprite.getchannel('A').point(lambda x:255 if x>120 else 0)
    sprite=sprite.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA')
    sprite.putalpha(alpha)
    x=round(CELL[0]/2+(box[0]-cx)*scale)
    y=BASELINE-size[1]
    assert x>=0 and y>=0 and x+size[0]<=CELL[0], 'pose would clip'
    frame=Image.new('RGBA',CELL)
    frame.alpha_composite(sprite,(x,y))
    blade=Image.new('L',CELL)
    if source_index in low_swords:
        points=[(round(x+(px-box[0])*scale),round(y+(py-box[1])*scale)) for px,py in low_swords[source_index]]
        ImageDraw.Draw(blade).line(points,fill=255,width=7)
    weapon_masks.append(np.array(blade)>0)
    poses.append(frame)
    hips.append((80,round(BASELINE-(box[3]-cy)*scale)))
# Last return pose is the opening finisher pose: preserve the raised-sword handoff.
indices=list(range(16))+[15,16,17,18,19,20,21,23]
planted=Image.new('RGBA',(CELL[0]*8,CELL[1]*3))
for i,source in enumerate(indices): planted.alpha_composite(poses[source],(i%8*CELL[0],i//8*CELL[1]))
planted.save(OUT/'planted.png')
# Align by each drawing's hip rather than slicing every torso at a fixed y.
run=Image.open(ROOT/'art/characters/fluid-v001/run.png').convert('RGBA')
moving=Image.new('RGBA',(CELL[0]*8,CELL[1]*24))
for gait in range(8):
    original=run.crop((gait%4*128,gait//4*96,gait%4*128+128,gait//4*96+96))
    leg=Image.new('RGBA',CELL);leg.alpha_composite(original,(16,32))
    # The existing gait atlas was aligned to a common waist at y=55.
    ImageDraw.Draw(leg).rectangle((0,0,159,86),fill=(0,0,0,0))
    ImageDraw.Draw(leg).rectangle((98,87,159,99),fill=(0,0,0,0))
    for i,source in enumerate(indices):
        upper=np.array(poses[source]); yy,xx=np.indices(upper.shape[:2])
        hip_y=hips[source][1]
        # Keep trailing red cape and the actual weapon, never planted boots.
        rgb=upper[:,:,:3].astype(int)
        cape=(rgb[:,:,0]>55)&(rgb[:,:,0]>rgb[:,:,1]*1.5)&(rgb[:,:,0]>rgb[:,:,2]*1.25)
        upper[(yy>hip_y+3)&~cape&~weapon_masks[source]]=0
        top=Image.fromarray(upper)
        frame=leg.copy()
        frame.alpha_composite(top,(0,86-hip_y))
        moving.alpha_composite(frame,(i%8*CELL[0],(i//8*8+gait)*CELL[1]))
moving.save(OUT/'moving.png')
review=Image.new('RGB',planted.size,(22,31,43));review.paste(planted,(0,0),planted)
review.save(OUT/'contact.png')
print('24 staged poses, 192 moving combinations, fixed foot baseline; hip heights',hips)
