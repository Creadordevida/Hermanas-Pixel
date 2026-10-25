"""0.9.0 clothing adaptation. Operates ONLY on copies of original approved player sprites.
Top faces/hair are byte-identical. Output is ACTUAL PNG loaded at runtime.
Never changes the approved frames in assets/images/frames.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np
from scipy.ndimage import gaussian_filter,binary_erosion
import hashlib
ROOT=Path(__file__).resolve().parents[1]/'assets/images'
POSES=('idle_0','walk_0','walk_1','jump_0')
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'

for role in ('futbolista','bailarina'):
 for pose in POSES:
  source=Image.open(ROOT/'frames'/f'{role}_{pose}.png').convert('RGBA')
  a=np.array(source).copy(); orig=a.copy()
  h,w=a.shape[:2]; Y,X=np.mgrid[:h,:w]
  r,g,b,alp=[orig[:,:,i].astype(np.float32) for i in range(4)]
  visible=alp>70
  lum=(.3*r+.59*g+.11*b)
  def tint(mask,base,low,high):
   # Original volume/creases shading retained; do not flatten art.
   factor=np.clip(.56+(lum/175)*.58,.46,1.24)
   for ch,val in enumerate(base):
    target=np.clip(factor*val+(lum-98)*.08,0,255).astype('uint8')
    a[:,:,ch][mask]=target[mask]
  if role=='futbolista':
   # Original face and ponytail untouched above neck. Protect skin and hair everywhere.
   torso=(Y>h*.285)&(Y<h*.562)
   # Cover ALL blouse pixels including printed lettering, not merely dark ones.
   # This avoids the sweatshirt's original logo bleeding through the uniform.
   skin=(r>g*1.16)&(g>b*1.17)&(r>105)
   hair=(r>107)&(r>g*1.19)&(g>b*1.24)&(g>67)
   jersey=visible&torso&~(skin|hair)
   # Reconstruct textile volume from smoothed fabric shading rather than transferring
   # bright WHITE original chest lettering into the yellow match shirt.
   shade=gaussian_filter(lum,sigma=3.2)
   light=np.clip(.75+np.minimum(shade,150)/380.,.77,1.14)
   for ch,val in enumerate((245,204,45)):
    a[:,:,ch][jersey]=np.clip(light[jersey]*val,0,255).astype('uint8')
   # Retain some original dark ink at contours for authentic pixel shading.
   boundary=jersey&(lum<39)
   for ch,val in enumerate((45,66,104)):
    a[:,:,ch][boundary]=np.clip(.40*a[:,:,ch][boundary]+.60*val,0,255).astype('uint8')
   # Restrict stripe to cloth only; seams are blue, blue neck trim.
   cuffs=jersey&(Y>h*.37)&(Y<h*.53)&((X<w*.40)|(X>w*.74))
   for col,val in enumerate((40,78,169)):a[:,:,col][cuffs]=np.clip(a[:,:,col][cuffs]*.25+val*.75,0,255)
   # Turn trouser upper part into blue football shorts, with a gold side stripe.
   jeans=visible&(Y>h*.55)&(Y<h*.91)&(b>r*1.22)&(b>g*1.08)
   shorts=jeans&(Y<h*.688)
   tint(shorts,(39,89,196),0,255)
   # Long trousers become two exposed legs and two pairs of shin socks.
   leg=jeans&(Y>=h*.688)&(Y<h*.875)
   tint(leg,(234,171,121),0,255)
   # Blue jean creases should not look like denim anymore; use soft local highlights.
   for ch, val in enumerate((229,166,124)):
    current=a[:,:,ch].astype(np.float32)
    smooth=gaussian_filter(current,sigma=2.5)
    a[:,:,ch][leg]=np.clip(.85*smooth[leg]+.15*current[leg]+(val-(229,166,124)[ch])*.2,0,255).astype('uint8')
   socks=leg&(Y>h*.79)
   tint(socks,(236,240,247),0,255)
   # Shirt numeral is drawn inside visible jersey region, not on a hoodie pocket.
   img=Image.fromarray(a,'RGBA')
   draw=ImageDraw.Draw(img)
   jersey_coords=np.where(jersey&(Y>h*.37)&(Y<h*.53))
   if len(jersey_coords[0]):
    yy=int(np.median(jersey_coords[0])); xx=int(np.median(jersey_coords[1]));
    fs=14 if pose!='jump_0' else 13
    font=ImageFont.truetype(FONT,fs)
    draw.text((int(w*.61),int(h*.46)),'19',font=font,anchor='mm',fill=(20,42,100,255),stroke_width=0)
   # Elegant blue collar/side-panel accents: painted only within torso cloth mask.
   a=np.array(img)
  else:
   # Preserve Sara's unique face/ponytail and bare arms exactly.
   torso=(Y>h*.365)&(Y<h*.680)&(X>w*.16)&(X<w*.87)
   dark_shirt=(r<157)&(g<157)&(b<160)
   logo_red=(r>130)&(g<115)&(b<133)
   logo_white=(r>155)&(g>155)&(b>155)&(Y<h*.60)
   cloth=visible&torso
   # Exclude skin and hair no matter where pose moves arms.
   skin=(r>g*1.18)&(g>b*1.13)&(r>118)
   hair=(r>g*1.16)&(g>b*1.20)&(g>95)
   cloth &= ~(skin|hair)
   soft=gaussian_filter(lum,sigma=3.0)
   level=np.clip(.75+np.minimum(soft,140)/375,.78,1.12)
   for ch,val in enumerate((128,229,198)):
    a[:,:,ch][cloth]=np.clip(level[cloth]*val,0,255).astype('uint8')
   darkedge=cloth&(lum<37)
   for ch,val in enumerate((40,116,111)):
    a[:,:,ch][darkedge]=np.clip(.5*a[:,:,ch][darkedge]+.5*val,0,255).astype('uint8')
   # Recolor dark leggings as pale ballet tights, preserving original anatomy.
   trousers=visible&(Y>h*.61)&(Y<h*.87)&(r<132)&(g<145)&(b<154)
   tights=trousers&~cloth
   # Smooth pale-pink tights; original leggings have black crease pigments.
   smooth=gaussian_filter(lum,sigma=3.4)
   amount=np.clip(.88+np.minimum(smooth,125)/500,.88,1.1)
   for ch,val in enumerate((247,205,221)):
    a[:,:,ch][tights]=np.clip(val*amount[tights],0,255).astype('uint8')
   # Turn shoelace whites into tone-on-tone, keeping shoe pixel shading.
   # Highlight neckline and waist, but only within actual original shape.
   band=cloth&(Y>h*.595)&(Y<h*.62)
   for ch,val in enumerate((39,161,140)):
    a[:,:,ch][band]=np.clip(a[:,:,ch][band]*.45+val*.55,0,255)
   # Ballet slippers are pink, as requested, keep the original outlines and feet size.
   shoe_zone=visible&(Y>h*.815)&(r<155)&(g<150)&(b<168)
   for ch,val in enumerate((212,106,154)):
    a[:,:,ch][shoe_zone]=np.clip(a[:,:,ch][shoe_zone]*.55+val*.45,0,255)
  # Important hard guard: no pixel before the lower face boundary may change.
  cutoff=int(h*(.265 if role=='futbolista' else .35))
  a[:cutoff]=orig[:cutoff]
  if role=='futbolista':
   # Preserve the ENTIRE approved face and its outline, not just the forehead.
   face_guard=(Y<h*.365)&(X>w*.43)
   a[face_guard]=orig[face_guard]
  # No change to silhouette/alpha, preserving sprite positioning and hitbox.
  a[:,:,3]=orig[:,:,3]
  Image.fromarray(a,'RGBA').save(ROOT/'outfits'/f'{role}_{pose}.png')
  assert np.array_equal(orig[:cutoff],a[:cutoff]),(role,pose,'face changed')
  assert np.array_equal(orig[:,:,3],a[:,:,3]),(role,pose,'silhouette changed')
  print(role,pose, 'changed',int(np.count_nonzero(np.any(a[:,:,:3]!=orig[:,:,:3],axis=2))), 'unchanged alpha:',True)
