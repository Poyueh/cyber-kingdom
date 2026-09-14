"""Rebuild the foundry background with nearest-neighbor sampling; requires Pillow."""
from pathlib import Path
from PIL import Image


def build():
    art = Path(__file__).resolve().parent.parent / "art/environments/foundry"
    output = art / "processed/foundry-v001.png"
    output.parent.mkdir(exist_ok=True)
    with Image.open(art / "source/foundry-v001.png") as source:
        source.resize((900, 300), Image.Resampling.NEAREST).save(output)
    print(output)


if __name__ == "__main__":
    build()
