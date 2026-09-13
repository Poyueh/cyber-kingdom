#!/usr/bin/env python3
"""Bundle the maintained player guide into one offline HTML file."""
from pathlib import Path
import argparse
import base64
import mimetypes
import re

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs/player-guide'

def build(output: Path) -> Path:
    html = (SOURCE / 'index.html').read_text(encoding="utf-8")
    css = (SOURCE / 'style.css').read_text(encoding="utf-8")
    script = (SOURCE / 'guide.js').read_text(encoding="utf-8")
    html = html.replace('<link rel="stylesheet" href="style.css">', '<style>\n' + css + '\n</style>')
    html = html.replace('<script src="guide.js" defer></script>', '<script>\n' + script + '\n</script>')
    def embed(match):
        source = (SOURCE / match.group(1)).resolve()
        if not source.is_relative_to(SOURCE.resolve()):
            raise ValueError('Asset outside player guide: ' + match.group(1))
        mime = mimetypes.guess_type(source.name)[0] or 'application/octet-stream'
        return '"data:' + mime + ';base64,' + base64.b64encode(source.read_bytes()).decode() + '"'
    html = re.sub(r'"(assets/[^"\n]+)"', embed, html)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(html, encoding="utf-8")
    return output

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'builds/player-guide/Cyber-Kingdom-玩家指南.html')
    args = parser.parse_args()
    result = build(args.output)
    print(f'{result}\n{result.stat().st_size / 1024 / 1024:.2f} MiB; assets embedded, no network required.')
