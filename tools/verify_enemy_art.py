"""Fail if a legacy generator replaces illustrated enemy resources.
Checks byte identity, actual alpha, nonempty poses, and unique keyframes.
These checks do not constitute artistic approval or gameplay verification.
"""
from pathlib import Path
import hashlib,json
from PIL import Image
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'qa/enemy_art_20261031/locked_asset_hashes.json').read_text())
for name,expected in manifest.items():
    p=root/name
    assert hashlib.sha256(p.read_bytes()).hexdigest()==expected, f'Art overwritten: {name}'
    image=Image.open(p).convert('RGBA')
    assert image.getchannel('A').getextrema()==(0,255), f'Invalid transparency: {name}'
    if name.endswith('_atlas.png'):
        w,h=image.width//4,image.height//6
        frames=[image.crop((x*w,y*h,(x+1)*w,(y+1)*h)) for y in range(6) for x in range(4)]
        assert all(f.getbbox() for f in frames), f'Empty animation frame: {name}'
        assert len({hashlib.sha256(f.tobytes()).hexdigest() for f in frames})==24, f'Duplicate animation poses: {name}'
print(f'Illustrated enemy integrity: {len(manifest)} PNGs passed')
