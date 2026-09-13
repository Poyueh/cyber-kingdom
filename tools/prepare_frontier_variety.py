from pathlib import Path
from PIL import Image
import numpy as np
from prepare_resident_motion import cutout
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/frontier/variety-v001'
NAMES=['fir','oak','dead_tree','cedar','log','mushrooms','arch','dragon_statue','basalt','quartz','gear','ferns']
HEIGHTS=[184,172,160,184,48,30,138,132,68,66,54,36]
def main():
    source=Image.open(OUT/'sources/props.png')
    rows=[0,412,716,1024]
    for i,name in enumerate(NAMES):
        row,col=divmod(i,4)
        im=cutout(source.crop((col*384,rows[row],(col+1)*384,rows[row+1])))
        # This scenic sheet contains neutral checkerboard islands enclosed by branches.
        # Its natural palette uses colored highlights, so remove the neutral backdrop inside too.
        pixels=np.array(im)
        rgb=pixels[:,:,:3].astype(int)
        backdrop=(rgb.max(2)-rgb.min(2)<40)&(rgb.min(2)>150)
        pixels[:,:,3][backdrop]=0
        im=Image.fromarray(pixels)
        im=im.crop(im.getbbox());scale=HEIGHTS[i]/im.height
        im.resize((round(im.width*scale),HEIGHTS[i]),Image.Resampling.NEAREST).save(OUT/(name+'.png'))
if __name__=='__main__':main()
