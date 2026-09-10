"""Reproduce game sprites from the original built-in image generation output."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'art/campaign/v001'
source=Image.open(folder/'sources/props.png').convert('RGBA')
print('Native alpha range:',source.getchannel('A').getextrema())
w,h=source.size
for name,col,row,height in [('campfire',0,0,94),('stone',1,0,72),('herbs',0,1,48),('plot',1,1,64)]:
    im=source.crop((col*w//2,row*h//2,(col+1)*w//2,(row+1)*h//2))
    alpha=im.getchannel('A').point(lambda a: 255 if a>=48 else 0)
    im.putalpha(alpha)
    im=im.crop(alpha.getbbox())
    im=im.resize((round(im.width*height/im.height),height),Image.Resampling.NEAREST)
    im.save(folder/(name+'.png'))
