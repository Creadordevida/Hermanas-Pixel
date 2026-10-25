"""Create complete sideways defeat poses from each enemy's repaired intact pose.
The original referee and teacher defeat PNGs omitted entire limbs.
"""
from PIL import Image
from pathlib import Path
p=Path(__file__).resolve().parents[1]/'assets/images/enemies'
for kind,angle in [('referee',78),('teacher',82)]:
 src=Image.open(p/f'{kind}_0.png').convert('RGBA')
 out=src.rotate(angle,expand=True,resample=Image.Resampling.BICUBIC)
 a=out.getchannel('A').getbbox();out=out.crop(a)
 final=Image.new('RGBA',(out.width+14,out.height+14))
 final.alpha_composite(out,(7,7))
 final.save(p/f'{kind}_4.png')
print('Rebuilt complete referee and teacher horizontal defeat poses.')
