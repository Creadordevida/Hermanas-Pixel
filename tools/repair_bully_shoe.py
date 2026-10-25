from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np,shutil
root=Path(__file__).resolve().parents[1]
ref=Image.open(root/'reference/abuson_colegio_arte_aprobado.png').convert('RGBA')
# rear sneaker is partially occluded by a gold coin in reference screenshot;
# we recover its navy/white portions, excluding the golden pixels explicitly.
xy=(266,613,357,677)
cr=ref.crop(xy)
A=np.array(cr.convert('RGB'))
R,G,B=A[:,:,0],A[:,:,1],A[:,:,2]
not_gold=~((R.astype(int)>G.astype(int)*1.25)&(R.astype(int)>B.astype(int)*1.9)&(R>150))
navy=(B.astype(int)>R.astype(int)*.85)&(R<120)&(G<135)
white=(R>175)&(G>170)&(B>165)&((np.max(A,axis=2)-np.min(A,axis=2))<60)
valid=(navy|white)&not_gold
M=Image.new('L',cr.size,0);d=ImageDraw.Draw(M)
d.polygon([(9,29),(28,14),(63,9),(80,23),(88,35),(81,52),(25,54),(7,47)],fill=255)
valid=(valid&((np.array(M)>0))).astype('uint8')*255
pixel=Image.fromarray(np.dstack([A,valid]),'RGBA')
pixel=pixel.resize((int(cr.width*.47),int(cr.height*.47)),Image.Resampling.LANCZOS)
R=root/'assets/images/enemies';backup=root/'qa/enemy_originals_rc5'
for j in range(4):
 src=Image.open(backup/f'bully_{j}.png').convert('RGBA')
 canvas=Image.new('RGBA',(172,155))
 # upper body covers any shared pixels, while new sneaker is visible beyond
 # the right crop boundary of the original image.
 canvas.alpha_composite(pixel,(108,119))
 canvas.alpha_composite(src,(0,0))
 if bbox:=canvas.getchannel('A').getbbox():
  crop=canvas.crop(bbox);out=Image.new('RGBA',(crop.width+12,crop.height+12));out.alpha_composite(crop,(6,6))
  out.save(R/f'bully_{j}.png')
