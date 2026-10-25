"""Create original 16-bit-ish enemy frame PNGs; no approved character file overwritten."""
from pathlib import Path
from PIL import Image, ImageDraw
import math, numpy as np
ROOT=Path(__file__).resolve().parents[1]; DEST=ROOT/'assets/images/enemies'
DEST.mkdir(exist_ok=True)
# Hand-pixeled frames at native low res, alpha; details, shadows and accents.
def make_animal(kind,frame):
 sz=(100,88); im=Image.new('RGBA',sz);d=ImageDraw.Draw(im)
 bounce=[0,2,-1,1,0][frame]; motion=[-4,-2,0,3,0][frame]
 colors={
  'pigeon':('#45506f','#8896ae','#b9cbd7','#e2af5d'),
  'cat':('#513c39','#bb8551','#edba6d','#da8f90'),
  'rat':('#423d52','#817788','#ada2b0','#d99faa'),
 }[kind]
 dark,base,light,accent=colors
 if kind=='pigeon':
  wing=[(29,38,64,53),(20,20,61,47),(25,12,64,43),(32,26,76,55),(35,40,65,51)][frame]
  d.polygon([(17,55+bounce),(41,41+bounce),(70,55+bounce),(62,66+bounce),(29,69+bounce)],fill=dark)
  d.ellipse((20,35+bounce,67,66+bounce),fill=base,outline=dark,width=3)
  d.polygon([(wing[0],wing[3]+bounce),(wing[0]+6,wing[1]+bounce),(wing[2],wing[1]+8+bounce),(wing[2]-5,wing[3]+bounce)],fill=light,outline=dark)
  d.ellipse((52,34+bounce,76,58+bounce),fill=base,outline=dark,width=3)
  d.polygon([(74,44+bounce),(89,51+bounce),(73,56+bounce)],fill=accent,outline=dark)
  d.ellipse((63,43+bounce,69,49+bounce),fill='#eefafa');d.point((66,46+bounce),fill='#202631')
  d.line((42,67+bounce,39,78+bounce),fill=accent,width=3);d.line((57,66+bounce,55,77+bounce),fill=accent,width=3)
  for x in [34,54]:d.line((x-7,78+bounce,x+8,78+bounce),fill=dark,width=2)
 elif kind=='cat':
  d.arc((8+motion,24,50+motion,75),90,285,fill=dark,width=7)
  d.arc((9+motion,22,49+motion,73),90,285,fill=base,width=4)
  body=(18+motion,38+bounce,69+motion,74+bounce)
  d.ellipse((body[0]-2,body[1]+3,body[2]+3,body[3]+4),fill=dark)
  d.ellipse(body,fill=base)
  for x in [24+motion,58+motion]:
   d.rounded_rectangle((x,66+bounce,x+11,80+bounce),3,fill=base,outline=dark,width=2)
  d.polygon([(57+motion,40+bounce),(60+motion,18+bounce),(71+motion,30+bounce),(81+motion,19+bounce),(87+motion,44+bounce)],fill=dark)
  d.polygon([(61+motion,40+bounce),(63+motion,26+bounce),(71+motion,35+bounce),(79+motion,26+bounce),(83+motion,44+bounce)],fill=base)
  d.ellipse((57+motion,34+bounce,88+motion,68+bounce),fill=base,outline=dark,width=2)
  d.ellipse((64+motion,46+bounce,70+motion,51+bounce),fill='#fff2ae');d.ellipse((78+motion,46+bounce,84+motion,51+bounce),fill='#fff2ae')
  d.point((67+motion,49+bounce),fill='#292436');d.point((81+motion,49+bounce),fill='#292436')
  d.polygon([(71+motion,57+bounce),(76+motion,57+bounce),(74+motion,61+bounce)],fill=accent)
  for y in [57,61]:
   d.line((60+motion,y+bounce,47+motion,y-4+bounce),fill=dark,width=1)
   d.line((85+motion,y+bounce,98+motion,y-3+bounce),fill=dark,width=1)
  d.arc((28+motion,41+bounce,61+motion,70+bounce),0,95,fill=light,width=3)
 else:
  # Big scrollable rat silhouette, curved tail, whiskers, pink ears/feet.
  d.arc((4+motion,43+bounce,55+motion,83+bounce),150,350,fill=accent,width=4)
  d.ellipse((22+motion,46+bounce,69+motion,72+bounce),fill=dark)
  d.ellipse((25+motion,45+bounce,67+motion,67+bounce),fill=base)
  d.ellipse((49+motion,36+bounce,78+motion,67+bounce),fill=dark)
  d.ellipse((53+motion,38+bounce,79+motion,64+bounce),fill=base)
  for x,y in [(54,35),(69,35)]:
   d.ellipse((x+motion,y+bounce,x+13+motion,y+13+bounce),fill=dark)
   d.ellipse((x+3+motion,y+2+bounce,x+10+motion,y+10+bounce),fill=accent)
  d.ellipse((72+motion,47+bounce,87+motion,59+bounce),fill=light)
  d.ellipse((84+motion,51+bounce,91+motion,56+bounce),fill=accent)
  d.ellipse((69+motion,43+bounce,75+motion,49+bounce),fill='white');d.point((72+motion,45+bounce),fill=dark)
  for j in range(2):
   d.line((84+motion,56+j*3+bounce,99+motion,51+j*6+bounce),fill=dark,width=1)
  for x in [30+motion,58+motion]:d.line((x,66+bounce,x+2,76+bounce),fill=accent,width=4)
 if frame==4: # comic defeat swirl
  d.arc((17,5,79,29),180,355,fill='#e6c955',width=3)
  for x,y in [(25,13),(74,8),(49,4)]:d.text((x,y),'*',fill='#ffcf4b')
 return im.resize((200,176),Image.Resampling.NEAREST)
for kind in ['pigeon','cat','rat']:
 for frame in range(5):make_animal(kind,frame).save(DEST/f'{kind}_{frame}.png')
# Humanoid derivative animation: preserve richly shaded source outlines and pose motion.
# Make visually distinguishable new enemies without modifying Miren/Sara/father original assets.
from PIL import ImageFont
def materialize(src_file,style,frame):
 im=Image.open(src_file).convert('RGBA')
 pix=np.array(im);a=pix[:,:,3];c=pix[:,:,:3].astype(float)
 h,w=a.shape; yy,xx=np.indices((h,w))
 if style=='bully':
  # Rival soccer sprite recolored from red kit to purple oversize-school top.
  red=(c[:,:,0]>c[:,:,1]*1.3)&(c[:,:,0]>c[:,:,2]*1.23)&(yy<h*.8)&(a>40)
  lum=np.clip((c[:,:,0]+c[:,:,1]+c[:,:,2])/3,0,255)
  pix[red,0]=np.clip(lum[red]*.27+34,0,255).astype('uint8');pix[red,1]=np.clip(lum[red]*.38+48,0,255).astype('uint8');pix[red,2]=np.clip(lum[red]*.50+74,0,255).astype('uint8')
  im=Image.fromarray(pix)
  d=ImageDraw.Draw(im); x=int(w*.64);y=int(h*.44)
  d.rounded_rectangle((x,y,x+int(w*.18),y+int(h*.25)),3,fill='#ac7742',outline='#3d2c31',width=2)
  d.line((x+2,y+2,x+2,y+int(h*.22)),fill='#e9b368',width=2)
 elif style=='statue':
  present=a>20; g=(c[:,:,0]*.23+c[:,:,1]*.60+c[:,:,2]*.17)
  pix[present,0]=np.clip(g[present]*.47+70,0,255).astype('uint8')
  pix[present,1]=np.clip(g[present]*.54+62,0,255).astype('uint8')
  pix[present,2]=np.clip(g[present]*.36+22,0,255).astype('uint8')
  im=Image.fromarray(pix)
 elif style=='teacher':
  # Muted greys in clothing; eyes preserved; paper with red grade.
  suit=(yy>h*.25)&(yy<h*.75)&(c[:,:,0]<130)&(c[:,:,1]<140)&(a>45)
  pix[suit,0]=np.clip(c[suit,0]*.46+49,0,255).astype('uint8')
  pix[suit,1]=np.clip(c[suit,1]*.33+45,0,255).astype('uint8')
  pix[suit,2]=np.clip(c[suit,2]*.42+61,0,255).astype('uint8')
  im=Image.fromarray(pix);d=ImageDraw.Draw(im)
  x=int(w*.69); y=int(h*.43)
  d.polygon([(x,y),(min(w-2,x+32),y+4),(min(w-2,x+28),min(h-2,y+37)),(x-2,y+31)],fill='#fff6df',outline='#29283e',width=2)
  d.text((x+7,y+8),'3',fill='#e33d45',stroke_width=1,stroke_fill='#f18b7a')
  # Black-framed glasses and wispy eyebrow to differentiate dad.
  eye_y=int(h*.17)
  d.line((int(w*.57),eye_y,int(w*.85),eye_y),fill='#383543',width=2)
 return im
for kind in ['bully','teacher','statue']:
 for i in range(5):
  if kind=='bully':path=DEST/f'rival_{[0,1,2,3,4][i]}.png'
  elif kind=='teacher':path=DEST/f'referee_{[0,1,2,3,4][i]}.png'
  else:
   files=ROOT/'assets/images/frames'
   path=files/(('padre_walk_0' if i in (1,3) else 'padre_walk_1' if i==2 else 'padre_idle_0' if i==0 else 'padre_jump_0')+'.png')
  materialize(path,kind,i).save(DEST/f'{kind}_{i}.png')
print('Generated 30 animated pixel enemy frames (3 animals, 3 humanoid derivatives).')
