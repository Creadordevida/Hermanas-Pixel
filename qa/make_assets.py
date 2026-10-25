"""Deterministic 0.9.0 asset builder; source approved PNGs are NEVER rewritten."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageFilter
import math, random, colorsys
import numpy as np
P=Path(__file__).resolve().parents[1]; AS=P/'assets/images'; random.seed(901)
(AS/'enemies').mkdir(exist_ok=True);(AS/'props').mkdir(exist_ok=True);(AS/'outfits').mkdir(exist_ok=True)
# Preserve the eight approved dog images: recolor via RGB scaling only, do not alter alpha.
for variant in ['dalmatian','doberman']:
 (AS/'dog'/variant).mkdir(exist_ok=True)
 for src in sorted((AS/'dog').glob('*.png')):
  im=Image.open(src).convert('RGBA'); arr=np.array(im); a=arr[:,:,3]; rgb=arr[:,:,:3].astype(np.float32)
  if variant=='dalmatian':
   # Keep existing silhouettes/expression, recolor primarily warm coat pixels.
   warm=(rgb[:,:,0] > rgb[:,:,2]*1.18)&(rgb[:,:,0]>rgb[:,:,1]*1.08)&(a>0)
   l=(.33*rgb[:,:,0]+.56*rgb[:,:,1]+.11*rgb[:,:,2]); white=np.clip(l*0.40+145,0,245)
   for j in range(3): arr[:,:,j]=np.where(warm,white,arr[:,:,j]).astype('uint8')
   for cy,cx in [(32,46),(55,77),(64,37),(39,109)]:
    yy,xx=np.ogrid[:im.height,:im.width]; blob=((xx-cx)**2/72+(yy-cy)**2/43)<1
    mask=blob & warm & (a>90)
    arr[mask,:3]=[39,38,47]
  else:
   warm=(rgb[:,:,0]>rgb[:,:,2]*1.13)&(a>0)
   dark=(rgb[:,:,0]*.13+rgb[:,:,1]*.10+rgb[:,:,2]*.07+13)
   for j in range(3): arr[:,:,j]=np.where(warm,dark+(j==2)*6,arr[:,:,j]).astype('uint8')
   tan=warm & (np.indices(warm.shape)[0]>58)&(np.indices(warm.shape)[1]>77)
   arr[tan,:3]=[146,87,44]
  Image.fromarray(arr).save(AS/'dog'/variant/src.name)
# Create chapter costumes derived from approved original PNGs: pixel-safe recoloring with original face/hair/alpha.
for role in ['futbolista','bailarina']:
 for path in sorted((AS/'frames').glob(f'{role}_*.png')):
  a=np.array(Image.open(path).convert('RGBA')); yy,xx=np.indices(a.shape[:2]); rgb=a[:,:,:3].astype('int32'); alp=a[:,:,3]
  if role=='futbolista':
   # hoodie region: dark navy/black within torso, leaving blonde hair and facial pixels untouched.
   torso=(yy>a.shape[0]*.20)&(yy<a.shape[0]*.63)&(xx>a.shape[1]*.34)&(xx<a.shape[1]*.91)
   navy=(rgb[:,:,2]>=rgb[:,:,0]*.72)&(rgb[:,:,0]<110)&(rgb[:,:,1]<115)
   mask=torso & navy & (alp>15)
   lum=(rgb[:,:,0]+rgb[:,:,1]+rgb[:,:,2])/3
   a[mask,0]=np.clip(180+lum[mask]*.56,0,255).astype('uint8'); a[mask,1]=np.clip(138+lum[mask]*.52,0,255).astype('uint8'); a[mask,2]=np.clip(10+lum[mask]*.33,0,255).astype('uint8')
   pants=(yy>a.shape[0]*.59)&(yy<a.shape[0]*.91)&(rgb[:,:,2]>rgb[:,:,0]*1.03)&(alp>25)
   a[pants,0]=(rgb[pants,0]*.38).astype('uint8'); a[pants,1]=(rgb[pants,1]*.49).astype('uint8');a[pants,2]=np.clip(rgb[pants,2]*.82,0,255).astype('uint8')
  else:
   torso=(yy>a.shape[0]*.34)&(yy<a.shape[0]*.62)&(xx>a.shape[1]*.27)&(xx<a.shape[1]*.88)
   dark=(rgb[:,:,0]<95)&(rgb[:,:,1]<110)&(rgb[:,:,2]<115)&(alp>20)
   mask=torso & dark; lum=(rgb[:,:,0]+rgb[:,:,1]+rgb[:,:,2])/3
   a[mask,0]=np.clip(35+lum[mask]*.9,0,255).astype('uint8');a[mask,1]=np.clip(175+lum[mask]*.5,0,255).astype('uint8');a[mask,2]=np.clip(140+lum[mask]*.6,0,255).astype('uint8')
   # The original red logo is recolored rather than replaced with a generic silhouette.
   emblem=torso & (rgb[:,:,0]>rgb[:,:,1]*1.33)&(rgb[:,:,0]>rgb[:,:,2]*1.25)&(alp>25)
   a[emblem,:3]=[82,203,177]
   whites=torso & (xx>a.shape[1]*.45)&(xx<a.shape[1]*.78)&(yy>a.shape[0]*.4)&(rgb[:,:,0]>155)&(rgb[:,:,1]>155)&(rgb[:,:,2]>155)&(alp>25)
   a[whites,:3]=[151,224,204]
   legs=(yy>a.shape[0]*.52)&(yy<a.shape[0]*.92)&(rgb[:,:,0]<110)&(rgb[:,:,1]<110)&(alp>25)
   a[legs,0]=np.clip(rgb[legs,0]*.4+166,0,255).astype('uint8');a[legs,1]=np.clip(rgb[legs,1]*.3+117,0,255).astype('uint8');a[legs,2]=np.clip(rgb[legs,2]*.4+145,0,255).astype('uint8')
  im=Image.fromarray(a)
  if role=='futbolista':
   # Shirt number overlays only the torso; face and hair remain taken from approved sprites.
   d=ImageDraw.Draw(im)
   tx=int(im.width*.60); ty=int(im.height*.345)
   d.text((tx,ty),'19',fill='#234683',stroke_width=1,stroke_fill='#f5d368')
  im.save(AS/'outfits'/path.name)
# Gameplay prop art drawn at a 2x logical pixel scale, shaded with hard edges, transparent.
def draw_prop(name,fn):
 im=Image.new('RGBA',(80,80));d=ImageDraw.Draw(im);fn(d);im.save(AS/'props'/f'{name}.png')
def cone(d):
 d.ellipse((8,66,70,78),fill='#442719');d.polygon([(37,8),(19,64),(61,64)],fill='#f46a17',outline='#64260e',width=3)
 d.polygon([(29,35),(47,35),(52,45),(24,45)],fill='#fff9de');d.rectangle((14,63,66,71),fill='#e26c1f',outline='#47281c',width=2)
def planter(d):
 d.ellipse((10,60,70,77),fill='#443823');d.polygon([(15,42),(65,42),(57,70),(23,70)],fill='#bc6351',outline='#6a3533',width=3)
 for x,y,r,c in [(28,31,13,'#316e3b'),(51,24,16,'#438547'),(38,11,14,'#2f753a')]:d.ellipse((x-r,y-r,x+r,y+r),fill=c)
 for x,y,c in [(26,17,'#ff9ba9'),(40,12,'#efc447'),(56,31,'#f5b3d0'),(33,37,'#f98fa1')]:d.ellipse((x-6,y-6,x+6,y+6),fill=c,outline='#713a34',width=1)
def bag(d):
 d.ellipse((10,66,73,78),fill='#29273d');d.rounded_rectangle((20,15,62,69),10,fill='#335bb4',outline='#1f3055',width=4)
 d.arc((29,5,53,27),180,360,fill='#e8ba59',width=5);d.rounded_rectangle((28,35,55,58),5,fill='#527fc8',outline='#1d396a',width=3)
 d.line((21,29,12,54),fill='#253a65',width=6);d.line((61,28,71,57),fill='#253a65',width=6)
def bench(d):
 d.rectangle((8,34,74,42),fill='#a16a3e',outline='#513d31',width=3);d.rectangle((14,12,66,29),fill='#cd9454',outline='#624327',width=3)
 d.line((20,41,20,73),fill='#515e67',width=5);d.line((62,41,62,73),fill='#515e67',width=5)
def shoe(d):
 d.polygon([(14,39),(38,30),(50,44),(67,46),(74,58),(67,66),(15,66),(9,58)],fill='#e8eef1',outline='#263747',width=4)
 d.rectangle((14,56,73,63),fill='#d95347');d.line((33,38,48,43),fill='#335ab3',width=3)
def card(d):
 d.rounded_rectangle((20,12,57,68),3,fill='#f43228',outline='#4d1828',width=4)
 d.line((28,22,47,22),fill='#ff8e82',width=2)
def eraser(d):
 d.rounded_rectangle((9,25,69,58),6,fill='#296e9c',outline='#263b50',width=4)
 d.rectangle((14,46,65,58),fill='#e3d7be');d.line((18,29,56,29),fill='#7dbbd5',width=3)
def backpack(d): bag(d)
for n,f in [('cone',cone),('planter',planter),('backpack',backpack),('gym_bench',bench),('red_card',card),('shoe',shoe),('eraser',eraser)]:draw_prop(n,f)
# Detailed enemy extraction from user-approved preview sprite sheets. Background is near-uniform dark navy.
from PIL import ImageChops
source=P/'reference/CONCEPTO_ENEMIGOS_APROBADOS.png'
if source.exists():
 sheet=Image.open(source).convert('RGB')
 # Each box only encloses image sprite pixels; lower text labels excluded.
 specs={
 'rival':[(35,340,102,444),(144,340,207,444),(249,337,318,444),(450,335,517,449),(608,367,754,444)],
 'referee':[(783,339,851,450),(869,339,936,450),(959,336,1028,450),(1125,337,1199,449),(1399,372,1513,453)],
 'novice':[(18,834,92,961),(130,833,199,962),(238,826,307,961),(340,829,420,961),(581,891,744,960)],
 'breakdancer':[(778,840,839,957),(865,841,927,957),(949,846,1039,964),(1067,826,1161,958),(1399,897,1513,965)],
 }
 # Dark backdrop solid, with mild rightward gradient. Use border-color distance, flood connected background from border.
 import cv2
 for name,boxes in specs.items():
  for i,box in enumerate(boxes):
   c=np.array(sheet.crop(box)); hh,ww=c.shape[:2]
   # Mask bright/saturated pixels vs near-uniform dark blue background; mask contours anti-aliased.
   bg=np.median(np.vstack([c[0],c[-1],c[:,0],c[:,-1]]),axis=0)
   dist=np.sqrt(((c.astype(float)-bg)**2).sum(axis=2)); hsv=cv2.cvtColor(c,cv2.COLOR_RGB2HSV)
   signal=(dist>26)&((np.max(c,axis=2)>65)|(hsv[:,:,1]>110))
   # Remove border-connected background, keep sprite's larger connected component.
   n,labels,stats,ctr=cv2.connectedComponentsWithStats(signal.astype('uint8'),8)
   inds=[j for j in range(1,n) if stats[j,4]>=28]
   mask=np.zeros((hh,ww),dtype='uint8')
   for j in inds:mask[labels==j]=255
   # tightly crop and pad, leaving enough room to avoid accidental limb crop.
   if mask.any():
    ys,xs=np.where(mask>0); ymin=max(0,ys.min()-2); ymax=min(hh,ys.max()+3);xmin=max(0,xs.min()-2);xmax=min(ww,xs.max()+3)
    rgb=c[ymin:ymax,xmin:xmax]; alpha=mask[ymin:ymax,xmin:xmax]
    # Remove detached stray particles at sprite's edges.
    rgba=np.dstack([rgb,alpha]);out=Image.fromarray(rgba)
   else:out=Image.new('RGBA',(1,1))
   out.save(AS/'enemies'/f'{name}_{i}.png')
# Create stage-specific background plates from pixel-art source references, without replacing baseline approved levels.
scenes=AS/'scenes';scenes.mkdir(exist_ok=True)
concept=Image.open(P/'reference/CONCEPTO_FUTBOL_DANZA.png').convert('RGB')
# Build plates from environmental-only parts of the earlier user-approved concept.
# IMPORTANT: no characters, coins or dogs baked into gameplay backdrops.
foot=Image.new('RGB',(1320,480));d=ImageDraw.Draw(foot)
sky=concept.crop((330,65,1330,189)).resize((1320,242),Image.Resampling.LANCZOS)
foot.paste(sky,(0,0))
fence=concept.crop((390,177,1340,252)).resize((1320,134),Image.Resampling.LANCZOS)
foot.paste(fence,(0,242))
for y in range(376,480):
  green=int(85+14*math.sin(y*.15));d.line((0,y,1320,y),fill=(43,green+32,43),width=1)
for i in range(1700):
 x=random.randrange(1320);y=random.randrange(377,479);c=random.choice(['#6baf50','#8fc05b','#427634','#31652f'])
 d.line((x,y,x+random.randrange(-2,3),y-2),fill=c,width=1)
foot.save(scenes/'football.png')
# The studio is reconstructed from a clean wall + barres and a unified wooden floor.
ballet=Image.new('RGB',(1320,480),'#d2af8d')
wall=concept.crop((360,520,1365,654)).resize((1320,353),Image.Resampling.LANCZOS)
ballet.paste(wall,(0,0));d=ImageDraw.Draw(ballet)
for x in [0,440,880,1320]:
 d.line((x,0,x,353),fill='#9c6746',width=9)
for y in (273,289):
 d.line((0,y,1320,y),fill='#8d522c',width=9)
 d.line((0,y-3,1320,y-3),fill='#dfaa69',width=3)
for x in range(45,1320,135):
 d.line((x,281,x,347),fill='#6d7780',width=6)
 d.ellipse((x-5,279,x+5,291),fill='#d8b47c')
for y in range(353,480):
 t=y-353; d.line((0,y,1320,y),fill=(min(225,186+t//11),min(195,131+t//13),min(145,85+t//14)),width=1)
for y in range(367,480,27):d.line((0,y,1320,y),fill='#a16c45',width=3)
for x in range(0,1320,105):d.line((x,353,x+15,480),fill='#b98251',width=2)
ballet.save(scenes/'ballet.png')
# School follows palette and architectural forms from approved art: manually composed detailed tiles.
im=Image.new('RGB',(1320,480),(151,192,197));d=ImageDraw.Draw(im)
for y in range(0,480,6):
 c=int(177+22*math.sin(y/110));d.rectangle((0,y,1320,y+5),fill=(min(240,c+27),min(240,c+14),min(240,c)))
d.rectangle((0,0,1320,18),fill='#d0bb9b');d.rectangle((0,22,1320,34),fill='#a38a71')
for x in range(25,1320,276):
 d.rectangle((x,56,x+245,321),fill='#8b7061',outline='#5a4c48',width=6)
 d.rectangle((x+12,67,x+233,305),fill='#8ab8cf',outline='#d6c0a2',width=9)
 d.line((x+123,67,x+123,303),fill='#e5d6b5',width=8);d.line((x+16,178,x+227,178),fill='#e7dfc2',width=6)
 for cx in range(x+34,x+213,43):
  d.ellipse((cx,220,cx+26,275),fill='#769a8a')
d.rectangle((0,324,1320,480),fill='#bd966c');d.rectangle((0,332,1320,344),fill='#754832')
for y in range(354,480,27):
 d.line((0,y,1320,y),fill='#906c50',width=3)
for x in range(0,1320,88):d.line((x,343,x,479),fill='#cda177',width=2)
for x in [160,480,800,1090]:
 d.rectangle((x,286,x+95,304),fill='#9d6f46',outline='#543829',width=4)
 for k in [8,79]: d.line((x+k,302,x+k,348),fill='#593e35',width=6)
im.save(scenes/'school.png')
for variant in ('classroom','computers'):
 room=im.copy();dr=ImageDraw.Draw(room)
 # Reconstruct low walls over the corridor windows to show classroom interiors.
 dr.rectangle((0,0,1320,328),fill='#c8b8a4')
 for x in range(0,1320,240):
  dr.rectangle((x+14,53,x+214,266),fill='#835f4d',outline='#493f3d',width=5)
  dr.rectangle((x+22,61,x+206,255),fill='#7eacbb',outline='#d8caad',width=7)
  dr.line((x+117,61,x+117,255),fill='#e0d2b7',width=6)
 if variant=='classroom':
  dr.rectangle((420,37,900,238),fill='#3e665b',outline='#875934',width=18)
  dr.text((495,96),'A B C   1 2 3',fill='#eeeece')
 else:
  dr.rectangle((420,24,914,94),fill='#f8eaca',outline='#957359',width=7)
  dr.text((465,47),'AULA DE INFORMATICA',fill='#303d54')
 for x in range(45,1320,188):
  dr.rectangle((x,278,x+136,295),fill='#af764a',outline='#68452e',width=4)
  dr.line((x+12,292,x+12,363),fill='#6c503e',width=7)
  dr.line((x+123,292,x+123,363),fill='#6c503e',width=7)
  dr.rectangle((x+37,326,x+84,341),fill='#614837')
  if variant=='computers':
   dr.rounded_rectangle((x+39,221,x+106,279),5,fill='#394c5b',outline='#192c3a',width=5)
   dr.rectangle((x+46,228,x+98,265),fill='#6fb7c7')
   dr.rectangle((x+67,279,x+79,286),fill='#283842')
   dr.rectangle((x+40,290,x+110,295),fill='#c6c6b9')
  else:
   dr.rectangle((x+27,297,x+109,305),fill='#dec19a')
 room.save(scenes/f'school_{variant}.png')
# Game map, genuine generated PNG asset: city overview, seven visual markers are painted by Flutter for tap affordance.
W,H=1600,900;im=Image.new('RGB',(W,H),(85,151,117));d=ImageDraw.Draw(im)
for y in range(0,H,8):
 c=105+int(18*math.sin(y/65));d.rectangle((0,y,W,y+8),fill=(int(c*.63),c,int(c*.79)))
# Streets connect all districts, park paths and rivers.
roads=[[(0,430),(370,412),(725,465),(1160,350),(1600,295)],[(330,0),(410,220),(370,412),(510,680),(590,900)],[(1120,0),(1150,350),(1020,680),(990,900)],[(0,740),(510,680),(1020,680),(1600,720)]]
for line in roads:
 d.line(line,fill='#65727b',width=102,joint='curve');d.line(line,fill='#9b9c92',width=78,joint='curve');d.line(line,fill='#d8c8aa',width=3,joint='curve')
for x,y,w,h,colour in [(80,100,230,205,'#c58f66'),(530,75,310,240,'#c8a77c'),(1200,80,245,185,'#d7b886'),(230,540,215,205,'#ba8858'),(700,520,240,135,'#e2b67a'),(1160,565,260,220,'#9bbab3'),(680,740,220,120,'#ccaa79')]:
 d.rounded_rectangle((x+13,y+18,x+w+13,y+h+18),20,fill='#394e49')
 d.rounded_rectangle((x,y,x+w,y+h),16,fill='#714f3f',outline='#e3c8a0',width=8)
 d.polygon([(x-12,y+30),(x+w//2,y-40),(x+w+12,y+30)],fill=colour)
 for xx in range(x+24,x+w-20,52):
  for yy in range(y+40,y+h-24,62):
   d.rectangle((xx,yy,xx+27,yy+34),fill='#5b7a82',outline='#e9cf9f',width=4)
for i in range(140):
 x=random.randrange(0,W);y=random.randrange(0,H)
 if any(abs(x-a)<135 and abs(y-b)<115 for a,b in [(180,150),(680,140),(1310,130),(300,640),(835,580),(1270,665)]):continue
 rr=random.randint(10,25);d.ellipse((x-rr,y-rr,x+rr,y+rr),fill='#426e46',outline='#a3ae62',width=3);d.ellipse((x-rr//2,y-rr//2,x+rr//2,y+rr//2),fill='#65994e')
im.resize((1280,720),Image.Resampling.LANCZOS).save(AS/'map_pamplona.png')
print('Generated thematic resources and map; original approved files unchanged.')
