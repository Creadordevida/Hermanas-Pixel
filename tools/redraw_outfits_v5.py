"""Redraw specialty uniforms in-place on approved pose geometry.

Design constraints: protect hair, face, eyes, hands and original pose; re-form
neckline/sleeves, hem and shorts/tights; use texture-aware shading for the
new garment, avoid simple flat overlays. Original frames remain immutable.
"""
from pathlib import Path
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
ROOT=Path(__file__).resolve().parents[1]/'assets/images'
FRAMES=ROOT/'frames'; OUTFITS=ROOT/'outfits'

def is_skin(c):
 r,g,b=c
 return r>115 and r>g*1.05 and g>b*.95 and (r-b)>25 and (r-g)>4 and (g-b)>4

def is_hair(c):
 r,g,b=c
 return r>105 and r>g*1.22 and g>b*1.18 and b<180 and r-g>32

def transform(src,role,pose):
 img=src.convert('RGBA');arr=np.array(img).copy(); h,w=arr.shape[:2]
 yy,xx=np.indices((h,w))
 A=arr[:,:,3];R=arr[:,:,0].astype(float);G=arr[:,:,1].astype(float);B=arr[:,:,2].astype(float)
 # Stable pose-relative landmarks. Source poses are kept at their real dimensions.
 sh=int(h*.340) if role=='futbolista' else int(h*.350)
 waist=int(h*.606) if role=='futbolista' else int(h*.617)
 # Only opaque pixels are recolored, preserving source fabric folds.
 o=A>60
 color=np.zeros((h,w),bool)
 # Exclude original head/hair and flesh from fabric transforms.
 dark=((R<123)&(G<126)&(B<153)) | ((B>R*.8)&(G<115)&(R<115))
 skin=((R>110)&(R>G*1.08)&(G>B*.93)&((R-B)>27)&((G-B)>2))
 hair=((R>105)&(R>G*1.20)&(G>B*1.18)&(B<180)&((R-G)>30))
 center = .63*w if role=='futbolista' else .62*w
 # alpha of desired garment with subtle highlights from original luminance
 lum=(.24*R+.65*G+.11*B)/255
 def apply(mask,color_base, contrast=0.95):
  lo,mid,hi=color_base
  # fixed target midtones, keep local tonal structure without clipping
  variation=np.clip((lum[mask]-.26)*175*contrast,-48,59)
  rr=np.clip(lo+variation,0,255);gg=np.clip(mid+variation,0,255);bb=np.clip(hi+variation,0,255)
  arr[mask,:3]=np.stack([rr,gg,bb],axis=1).astype('uint8')
 if role=='futbolista':
  torso=o&(yy>=sh)&(yy<waist)&(xx>center-95)&(xx<center+65)&~hair&~skin
  # Original hoodie is stitched into the shirt, but the top hood is carved
  # into a round collar and short jersey sleeves on both arms.
  apply(torso&(dark | ((R<245)&(G<245)&(B<245))), (223,173,36),1.0)
  # make sleeve ends bare arms (a true sleeve-length change)
  arm_left=o&(yy>=int(h*.49))&(yy<int(h*.585))&(xx<center-30)&(xx>center-80)&dark&~hair
  arm_right=o&(yy>=int(h*.48))&(yy<int(h*.59))&(xx>center+25)&(xx<center+56)&dark
  apply(arm_left|arm_right,(228,153,109),.72)
  # Distinguish shirt neckline from hoodie: turn padded neck fold blue.
  hood=o&(yy>=int(h*.342))&(yy<int(h*.428))&(xx<center+26)&(xx>center-62)&dark&~hair&~skin
  apply(hood,(31,85,145),.65)
  # Blue shorts and actual exposed calves - separate textile pieces.
  shorts=o&(yy>=waist)&(yy<int(h*.717))&(B>R*1.07)&(B>G*.93)
  apply(shorts,(35,91,174),1.0)
  legs=o&(yy>=int(h*.719))&(yy<int(h*.795))&(B>R*1.05)&(B>G*.9)&~skin
  apply(legs,(225,151,112),.78)
  socks=o&(yy>=int(h*.795))&(yy<int(h*.875))&(B>R*1.05)&(B>G*.93)
  apply(socks,(228,235,238),.58)
 else:
  # Inpaint the Rolling Stones motif so the new leotard has unbroken fabric.
  import cv2
  bgr=cv2.cvtColor(np.array(img)[:,:,:3],cv2.COLOR_RGB2BGR)
  imprint=((R>120)&(R>G*1.3)&(R>B*1.2))|((R>180)&(G>180)&(B>180))
  central=(xx>center-25)&(xx<center+24)&(yy>=int(h*.44))&(yy<int(h*.57))
  rem=(imprint&central&o).astype('uint8')*255
  try:
   cleaned=cv2.inpaint(bgr,rem,5,cv2.INPAINT_TELEA)
   repaired=cv2.cvtColor(cleaned,cv2.COLOR_BGR2RGB)
   arr[central & (rem>0),:3]=repaired[central & (rem>0)]
   R=arr[:,:,0].astype(float);G=arr[:,:,1].astype(float);B=arr[:,:,2].astype(float)
   lum=(.24*R+.65*G+.11*B)/255
  except Exception: pass
  torso=o&(yy>=sh)&(yy<int(h*.65))&(xx>center-95)&(xx<center+64)&~skin&~hair
  apply(torso&(dark|((R<240)&(G<240)&(B<240))),(72,179,160),.87)
  # Sleeveless upper silhouette: sleeve fabric below shoulder becomes skin.
  left_sleeve=o&(yy>=int(h*.432))&(yy<int(h*.52))&(xx<center-25)&(xx>center-65)&dark&~hair
  right_sleeve=o&(yy>=int(h*.438))&(yy<int(h*.535))&(xx>center+16)&(xx<center+50)&dark
  apply(left_sleeve|right_sleeve,(237,172,132),.7)
  # tights continue seamlessly from hip to ankles, in blush-pink fabric
  tights=o&(yy>=int(h*.62))&(yy<int(h*.875))&(dark)&~skin&~hair
  apply(tights,(228,169,196),.69)
  # reduce bulky T-shirt hem into a close-fitted leotard
  hem=o&(yy>=int(h*.604))&(yy<int(h*.654))&(xx>center-38)&(xx<center+28)&~skin&~hair
  apply(hem,(55,159,145),.65)
  # light upper shoe panels look like practice footwear
  # leave real approved magenta shoes but soften bulky dark accents
  sneaker=o&(yy>=int(h*.865))&(R<125)&(G<95)&(B<125)&~hair
  apply(sneaker,(150,61,125),.65)
 # Real seam work, drawn on the reconstructed garment, never on faces.
 out=Image.fromarray(arr,'RGBA')
 d=ImageDraw.Draw(out,'RGBA')
 # Small visible, pose-aligned collar, highlights, shorts piping and dorsal
 if role=='futbolista':
  # collar throat below original jaw. Keep off the preserved head.
  y0=int(h*.403);x0=int(center+7)
  d.arc((x0-12,y0-4,x0+21,y0+9),start=0,end=155,fill=(25,82,155,220),width=max(2,int(h*.008)))
  # jersey diagonal blue flank stripe and subtle hem
  d.line([(center+31, int(h*.455)),(center+35,int(h*.51)),(center+27,waist-4)],fill=(28,91,163,170),width=max(3,int(h*.015)))
  d.line([(center-19,waist-6),(center+28,waist-6)],fill=(31,85,148,190),width=2)
  # textured No.19 on front panel
  try: font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',max(10,int(h*.046)))
  except: font=ImageFont.load_default()
  px=int(center+3); py=int(h*.485)
  d.text((px+1,py+1),'19',font=font,fill=(19,59,110,180))
  d.text((px,py),'19',font=font,fill=(20,81,157,255))
  # vertical football sock stripe
  d.line([(center-31,int(h*.814)),(center-32,int(h*.843))],fill=(33,89,161,195),width=2)
 else:
  # modest neckline for mint leotard, slim strap / waist seam
  y0=int(h*.424)
  d.arc((center-7,y0-4,center+24,y0+14), 15, 160,fill=(35,142,128,200),width=2)
  d.line([(center-24,int(h*.628)),(center+19,int(h*.632))],fill=(52,151,139,160),width=2)
 return out

def main():
 from hashlib import sha256
 result=[]
 for role in ['futbolista','bailarina']:
  for pose in ['idle_0','walk_0','walk_1','jump_0']:
   source=FRAMES/f'{role}_{pose}.png';dst=OUTFITS/f'{role}_{pose}.png'
   img=Image.open(source).convert('RGBA')
   dressed=transform(img,role,pose)
   if dressed.size!=img.size:raise RuntimeError('Frame dimensions changed')
   dressed.save(dst,optimize=True)
   result.append((dst.name,str(dressed.size),sha256(source.read_bytes()).hexdigest()[:10]))
 print('\n'.join(map(str,result)))
if __name__=='__main__': main()
