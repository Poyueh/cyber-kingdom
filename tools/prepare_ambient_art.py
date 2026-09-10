"""Reproduce in-game pixels from retained built-in imagegen outputs.
Local alpha cleanup/atlas alignment explicitly authorized by the project owner.
"""
from pathlib import Path
from PIL import Image
ROOT = Path(__file__).resolve().parents[1] / 'art/ambient/v001'
def clean(path):
    image = Image.open(path).convert('RGBA')
    image.putalpha(image.getchannel('A').point(lambda a: 255 if a > 160 else 0))
    return image
sheet = clean(ROOT / 'sources/wanderer-idle.png')
frames = []
for index in range(6):
    x, y = (index % 3) * 512, (index // 3) * 512
    cell = sheet.crop((x, y, x+512, y+512))
    frames.append(cell.crop(cell.getbbox()))
scale = 45 / max(frame.height for frame in frames)
atlas = Image.new('RGBA', (384, 64))
for index, frame in enumerate(frames):
    frame = frame.resize((round(frame.width*scale), round(frame.height*scale)), Image.Resampling.NEAREST)
    atlas.alpha_composite(frame, (index*64+32-frame.width//2, 61-frame.height))
atlas.save(ROOT / 'wanderer-idle.png')
chest = clean(ROOT / 'sources/chest-open.png')
chest = chest.crop(chest.getbbox())
chest.resize((52, round(chest.height*52/chest.width)), Image.Resampling.NEAREST).save(ROOT / 'chest-open.png')
