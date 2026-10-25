"""Add legs sourced from the approved school scene; avoid coins occluding right shoe."""
from PIL import Image, ImageDraw
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
R=ROOT/'assets/images/enemies'
REF=ROOT/'reference/profesora_colegio_arte_aprobado.png'
assert REF.is_file(), 'Se necesita arte de referencia para las piernas de la profesora'
source=Image.open(REF).convert('RGBA')
base=Image.new('RGBA',source.size,(0,0,0,0))
mask=Image.new('L',source.size,0); d=ImageDraw.Draw(mask)
# Silhouette follows visible skin and shoe exactly; no unedited floor or gold coins.
poly=[(157,526),(195,527),(194,546),(182,571),(173,589),(159,616),(144,635),(123,650),(101,658),(89,665),(85,655),(90,645),(111,642),(126,628),(140,606),(149,580)]
d.polygon(poly,fill=255)
left=Image.new('RGBA',source.size)
left.paste(source,(0,0),mask)
# The heel is dark and separated from skin by a sharp edge; restore the
# complete heel/shoe pixels from the same approved image rather than leaving
# the bare-pointed-foot silhouette in the first pass.
import cv2
raw=np.array(source.convert('RGB'))
shoe=np.zeros((raw.shape[0],raw.shape[1]),np.uint8)
patch=raw[619:670,80:164]
brightness=patch.mean(axis=2)
valid=(brightness < 107) & (np.max(patch,axis=2)<160)
shoe[619:670,80:164]=np.where(valid,255,0).astype('uint8')
shoe=cv2.morphologyEx(shoe,cv2.MORPH_CLOSE,np.ones((3,3),np.uint8))
shoe_mask=Image.fromarray(shoe,'L')
left.paste(source,(0,0),shoe_mask)
right=left.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
# mirror across source x=225 => x'=450-x ; whole source width 400, shift 50.
leg_image=Image.new('RGBA',(450,source.height))
leg_image.alpha_composite(left,(0,0));leg_image.alpha_composite(right,(50,0))
for idx in range(4):
 original=Image.open(ROOT/f'qa/enemy_originals_rc5/teacher_{idx}.png').convert('RGBA')
 complete=Image.new('RGBA',(175,270))
 # Original screenshot top of hair is at y=185, left body x=83. The original
 # isolated pixel-art torso is 130x177, equivalent to 260x354 in screenshot.
 legs=leg_image.crop((83,518,400,674)).resize((159,78),Image.Resampling.LANCZOS)
 clean=legs.copy()
 clean_alpha=clean.getchannel('A')
 # Ref screenshot includes a strip of indoor furniture behind top of knees.
 # Only retain original skin/shoes beginning just below skirt hem.
 for y in range(min(9,clean.height)):
  for x in range(clean.width):clean_alpha.putpixel((x,y),0)
 clean.putalpha(clean_alpha)
 complete.alpha_composite(clean,(0,169))
 complete.alpha_composite(original,(8,0))
 # Small, consistent transparent margin all around the sprite.
 b=complete.getchannel('A').getbbox()
 out=Image.new('RGBA',(b[2]-b[0]+12,b[3]-b[1]+12))
 out.alpha_composite(complete.crop(b),(6,6))
 out.save(R/f'teacher_{idx}.png')
print('Teacher complete source-backed legs attached in 4 standing poses.')
