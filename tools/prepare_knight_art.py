"""Rebuild normalized knight sheets. Requires Pillow and NumPy; no network.
The user authorized local background removal. Source PNGs are never overwritten.
"""
from collections import deque
import json
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ART = ROOT / 'art/characters/knight'
CELL = (128, 96)
ANCHOR = (64, 80)


def remove_checker_background(image):
    rgba = np.array(image.convert('RGBA'))
    rgb = rgba[:, :, :3].astype(np.int16)
    # Only remove light neutral pixels connected to the canvas edge. Dark
    # character outlines protect silver armor from becoming transparent.
    candidate = (rgb.max(2) - rgb.min(2) < 38) & (rgb.min(2) > 140)
    height, width = candidate.shape
    exterior = np.zeros((height, width), dtype=bool)
    queue = deque()
    for x in range(width):
        for y in (0, height - 1):
            if candidate[y, x] and not exterior[y, x]:
                exterior[y, x] = True
                queue.append((x, y))
    for y in range(height):
        for x in (0, width - 1):
            if candidate[y, x] and not exterior[y, x]:
                exterior[y, x] = True
                queue.append((x, y))
    while queue:
        x, y = queue.popleft()
        for nx, ny in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
            if 0 <= nx < width and 0 <= ny < height and candidate[ny,nx] and not exterior[ny,nx]:
                exterior[ny,nx] = True
                queue.append((nx,ny))
    rgba[exterior, 3] = 0
    return Image.fromarray(rgba)


def build(recipe_path=ART / 'animation-recipes.json'):
    recipe_path = Path(recipe_path).resolve()
    art = recipe_path.parent
    recipes = json.loads(recipe_path.read_text())
    output = art / 'processed'
    output.mkdir(exist_ok=True)
    for name, recipe in recipes.items():
        source = Image.open(art / recipe['source']).convert('RGBA')
        if recipe['remove_background']:
            source = remove_checker_background(source)
        columns = recipe['columns']
        rows = (len(recipe['frames']) + columns - 1) // columns
        sheet = Image.new('RGBA', (CELL[0]*columns, CELL[1]*rows))
        for index, frame in enumerate(recipe['frames']):
            x,y,w,h = frame['rect']
            rect = source.crop((x,y,x+w,y+h))
            scale = recipe['scale']
            resized = rect.resize((round(w*scale),round(h*scale)), Image.Resampling.NEAREST)
            # Binary pixel edges: the runtime uses nearest-neighbor filtering.
            resized.putalpha(resized.getchannel('A').point(lambda a: 255 if a >= 128 else 0))
            offset = (ANCHOR[0]-round(frame['anchor'][0]*scale), ANCHOR[1]-round(frame['anchor'][1]*scale))
            cell = Image.new('RGBA', CELL)
            cell.paste(resized, offset)
            sheet.paste(cell, ((index%columns)*CELL[0], (index//columns)*CELL[1]))
        destination = output / recipe.get('output', f'{name}-v001.png')
        sheet.save(destination)
        print(f'{name}: {sheet.size}, {len(recipe["frames"])} frames -> {destination.relative_to(ROOT)}')

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipes', type=Path, default=ART / 'animation-recipes.json')
    build(parser.parse_args().recipes)
