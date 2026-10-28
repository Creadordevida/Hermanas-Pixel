from PIL import Image,ImageDraw
from pathlib import Path
p=Path('/mnt/data/working_football/assets/images/enemies'); p.mkdir(parents=True,exist_ok=True)
def draw_pose(i):
 im=Image.new('RGBA',(128,128));d=ImageDraw.Draw(im)
 navy='#1d344a';green='#1c8e57'; light='#46c777'; skin='#e3a66c';hair='#3f2d26';white='#f2f2dc'; gold='#e7be5c'
 def poly(pts,c):d.polygon(pts,fill=c,outline=navy,width=2)
 def ell(b,c):d.ellipse(b,fill=c,outline=navy,width=2)
 if i==4:
  # grounded horizontal fall
  poly([(20,100),(71,101),(100,109),(98,119),(17,119)],navy);poly([(33,94),(74,86),(95,101),(79,114),(36,111)],green)
  ell((8,87,31,108),skin);ell((82,91,115,108),white)
 else:
  cx=58 if i!=2 else 44
  if i==1:
   legs=[[(40,73),(52,75),(46,112),(31,115)],[(65,75),(80,81),(92,101),(83,112)]]
  elif i==2:
   legs=[[(43,78),(57,75),(79,99),(69,110)],[(58,77),(72,72),(97,85),(91,96)]]
  else:
   legs=[[(43,78),(55,79),(52,113),(38,113)],[(62,79),(76,78),(80,113),(64,113)]]
  for pts in legs:poly(pts,navy)
  poly([(37,109),(53,108),(55,118),(32,119)],white);poly([(64,109),(83,108),(88,119),(63,119)],white)
  # chest
  poly([(36,43),(71,43),(82,78),(37,83),(29,70)],green)
  d.line([(43,50),(58,56),(73,49)],fill=light,width=4)
  d.rectangle((49,61,55,70),fill=gold)
  # face and hair
  ell((42,20,69,48),skin);poly([(40,26),(45,15),(65,14),(72,26),(58,21),(49,28)],hair)
  d.point((53,35),fill=navy);d.point((64,35),fill=navy)
  # arms + gloves: dive has dramatic extension
  if i==2:
   poly([(34,50),(23,42),(9,30),(4,39),(21,61),(33,67)],green);ell((0,25,15,41),white)
   poly([(71,47),(86,35),(102,24),(109,36),(94,48),(82,66)],green);ell((100,20,119,42),white)
  elif i==3:
   poly([(35,52),(18,48),(16,70),(27,74),(39,65)],green);ell((8,65,29,82),white)
   poly([(71,51),(86,60),(78,79),(66,77)],green);ell((72,70,91,86),white)
  else:
   poly([(35,51),(18,58),(13,80),(25,85),(37,67)],green);ell((6,75,29,96),white)
   poly([(72,51),(89,58),(93,80),(82,84),(72,67)],green);ell((77,75,101,96),white)
 if i==2:im=im.rotate(-13,Image.Resampling.NEAREST,expand=False)
 # scale native pixel to clearer game sprites (no interpolation)
 im.save(p/f'goalkeeper_{i}.png')
 return im
for i in range(5):draw_pose(i)
print('goalkeeper assets ready')
