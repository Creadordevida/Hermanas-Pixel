"""A reusable training fence tile without repeating the dugout every 640 px."""
from PIL import Image
import numpy as np
from pathlib import Path
r=Path(__file__).resolve().parents[1]/'assets/images/mid'
source=Image.open(r/'stage_4.png').convert('RGBA')
s=np.array(source).astype('float32');h,w=s.shape[:2]
# use the original artistically detailed fence + line of practice mannequins,
# preserving all vertical pixels of the original source (no flat-color paint).
start,end=360,639
pat=s[:,start:end].copy();period=pat.shape[1]
result=np.empty_like(s)
for x in range(w):result[:,x]=pat[:,x%period]
# join seam inside each repeated segment with a 16px patch blend.
for sx in range(0,w,period):
 for dx in range(16):
  x=sx+dx
  if x>=w: break
  f=(dx+1)/17
  result[:,x]=(1-f)*pat[:,period-16+dx]+f*result[:,x]
# force exact first/last-column agreement for adjacent copies.
result[:,-1]=result[:,0]
Image.fromarray(np.clip(result,0,255).astype('uint8'),'RGBA').save(r/'stage_4_plain.png')
