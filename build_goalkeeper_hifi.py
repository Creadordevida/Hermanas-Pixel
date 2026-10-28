from PIL import Image,ImageDraw
from pathlib import Path
import colorsys
p=Path(__file__).parent/'assets/images/enemies'
# Source: the approved running football character's pixel technique. Original files preserved.
hand_positions=[[(34,49),(48,55)],[(50,45),(65,52)],[(68,54),(80,51)],[(64,52),(80,48)],[(92,39),(108,43)]]
for i in range(5):
 im=Image.open(p/f'rival_{i}.png').convert('RGBA')
 pix=im.load()
 for y in range(im.height):
  for x in range(im.width):
   r,g,b,a=pix[x,y]
   if a<15:continue
   h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
   # Bright red shirt and shoes --> forest green + jade, retaining original pixel shading.
   if y>=38 and (h<.06 or h>.97) and s>.38 and r>g*1.36:
    k=max(.12,min(1.0,v));pix[x,y]=(int(27+34*k),int(77+125*k),int(42+51*k),a)
 d=ImageDraw.Draw(im)
 # Keeper gloves have white padded fingers and a navy cuff, attached to visible wrists.
 for x,y in hand_positions[i]:
  x=min(im.width-7,x);y=min(im.height-8,y)
  d.polygon([(x-3,y-2),(x+4,y-4),(x+8,y-1),(x+7,y+6),(x,y+7),(x-4,y+3)],fill='#e8f5f2',outline='#1d3341')
  d.line([(x,y+5),(x+6,y+3)],fill='#83b6ba',width=2)
 im.save(p/f'goalkeeper_{i}.png')
print('Derived goalkeeper poses created without modifying player originals')
