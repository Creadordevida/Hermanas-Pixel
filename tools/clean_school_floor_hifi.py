#!/usr/bin/env python3
"""School-only cleanup of an ugly polygonal plant in the old ground texture.
Protected stage_6.png remains untouched; use separate stage_6_hifi.png.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'assets/images/ground/stage_6.png'
OUTPUT=ROOT/'assets/images/ground/stage_6_hifi.png'
def main():
 if not SOURCE.is_file():raise FileNotFoundError(SOURCE)
 original=Image.open(SOURCE).convert('RGB')
 if original.size!=(540,202):raise ValueError('Wrong stage-6 ground geometry')
 donor=original.crop((290,0,375,63))
 clean=original.copy()
 clean.paste(donor,(99,0))
 mask=Image.new('L',original.size,0)
 ImageDraw.Draw(mask).rectangle((99,0,184,63),fill=255)
 mask=mask.filter(ImageFilter.GaussianBlur(6))
 output=Image.composite(clean,original,mask)
 OUTPUT.parent.mkdir(parents=True,exist_ok=True)
 output.save(OUTPUT,optimize=True)
 print('School hi-fi ground: polygonal plant removed, source protected')
if __name__=='__main__':main()
