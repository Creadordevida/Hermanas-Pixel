#!/usr/bin/env python3
"""Candidate Estafeta sprites in native pixel resolution, never a fake screenshot.

Each row has a meaningful pose (idle, alert, run, attack, hit, defeat);
four frames vary the feet and tail/scarf. ART REVIEW REQUIRED.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import json,hashlib,math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/images/enemies_new';OUT.mkdir(parents=True,exist_ok=True)
S=3
POSES=('idle','alert','run','attack','hit','defeated')
def outline(im):
 a=im.getchannel('A');big=a.filter(ImageFilter.MaxFilter(3))
 border=Image.new('RGBA',im.size,(28,27,32,0))
 border.putalpha(Image.frombytes('L',im.size,bytes(max(0,x-y) for x,y in zip(big.tobytes(),a.tobytes()))))
 border.alpha_composite(im)
 return border.resize((im.width*S,im.height*S),Image.Resampling.NEAREST)
def bull(p,n):
 im=Image.new('RGBA',(90,64));d=ImageDraw.Draw(im)
 movement=p in ('run','attack')
 step=(-3,2,4,-1)[n] if movement else 0
 # Defeat is a real fall, not a vertical displacement through the ground.
 low=3 if p=='attack' else 0
 # Four articulated legs and separate hooves. A rear pair is occluded.
 for x in (22,43,58,73):
  swing=step*(1 if x%2 else -1)
  top=37+low
  d.polygon([(x-5,top),(x+4,top),(x+5+swing,49+low),
     (x+2+swing,56+low),(x-5+swing,56+low),(x-7,46+low)],
     fill='#322c32',outline='#191e29')
  d.polygon([(x-5+swing,55+low),(x+3+swing,55+low),
     (x+5+swing,59+low),(x-8+swing,59+low)],fill='#181a23')
  d.line((x-5,40+low,x,47+low),fill='#665052',width=2)
 # Mammalian long back, shoulder hump, haunches, muscular chest.
 d.ellipse((12,17+low,72,49+low),fill='#3b3035',outline='#1c1f29',width=2)
 d.polygon([(17,29+low),(23,18+low),(38,12+low),
  (53,15+low),(66,24+low),(72,42+low),(59,45+low),
  (43,38+low),(24,44+low)],fill='#45363a')
 d.ellipse((47,18+low,77,47+low),fill='#302b31')
 d.arc((14,17+low,61,46+low),190,318,fill='#86615a',width=3)
 d.arc((24,22+low,68,44+low),205,308,fill='#644746',width=2)
 # Head and face angled towards the front of the charge.
 d.polygon([(62,24+low),(75,20+low),(85,27+low),
   (87,37+low),(80,45+low),(66,42+low),(59,34+low)],
   fill='#352c30',outline='#181b26')
 d.ellipse((73,35+low,87,44+low),fill='#91604b')
 d.point((82,39+low),fill='#221c24')
 d.point((76,30+low),fill='#d76d48')
 d.point((76,30+low),fill='#fde6af')
 d.line((68,27+low,76,25+low),fill='#131927',width=2)
 # Two asymmetrical curved horns, ivory with shaded roots.
 d.polygon([(67,26+low),(62,19+low),(64,11+low),
   (67,8+low),(66,17+low),(73,21+low)],fill='#dbc49b',outline='#725c52')
 d.polygon([(79,25+low),(81,18+low),(83,13+low),
   (85,13+low),(85,23+low)],fill='#efdeb6',outline='#847462')
 # Reworked head planes: horn roots, brow ridge, cheek, jaw, muzzle,
 # nostrils and rounded shoulder/hip muscles, all in native pixels.
 d.polygon([(19,22+low),(26,16+low),(43,15+low),(54,19+low),
            (50,23+low),(29,25+low),(18,30+low)],
           fill='#62464a')
 d.line((22,21+low,38,16+low,53,20+low),fill='#95716b',width=2)
 d.arc((14,24+low,43,46+low),175,320,fill='#261f29',width=2)
 d.arc((43,19+low,72,48+low),210,345,fill='#755454',width=2)
 d.polygon([(61,28+low),(67,24+low),(78,22+low),(82,26+low),
            (74,31+low),(68,33+low)],fill='#554047')
 d.polygon([(71,36+low),(78,32+low),(87,35+low),(88,41+low),
            (83,46+low),(75,43+low)],fill='#b17a63')
 d.line((76,42+low,85,43+low),fill='#6c463f',width=2)
 d.ellipse((83,37+low,86,40+low),fill='#352631')
 d.point((83,37+low),fill='#1b1c24')
 d.line((69,27+low,77,26+low),fill='#161923',width=3)
 d.line((71,24+low,76,23+low),fill='#a18070',width=1)
 d.ellipse((75,28+low,78,31+low),fill='#f9d99e')
 d.point((76,29+low),fill='#181d28')
 # Ivory horn roots are dark and broad; tips are light and tapered.
 d.line((66,23+low,64,18+low,65,12+low,67,9+low),
        fill='#eee2c4',width=2)
 d.line((79,24+low,83,18+low,84,13+low),fill='#fff0d1',width=2)
 d.line((65,23+low,68,26+low),fill='#80665a',width=3)
 d.line((79,23+low,81,25+low),fill='#7a6157',width=2)
 # Hoof rims and stretched flexor muscles move with the stride.
 for xx in (22,43,58,73):
  stride=step*(1 if xx%2 else -1)
  d.line((xx-6+stride,57+low,xx+4+stride,57+low),
         fill='#67616a',width=1)
  d.line((xx-3,42+low,xx+stride,49+low),
         fill='#6e5354',width=2)
 if p=='alert':
  # Ground scratch and snort are authored, not translated copies.
  d.arc((65,44,85,53),15,155,fill='#b89174',width=2)
  d.point((89,38),fill='#d3d1b8')
 elif p=='run':
  for q in range(n%3+1):
   d.line((6-q*3,56-q*2,10-q*3,54-q*2),fill='#a99484',width=1)
 elif p=='attack':
  d.line((78,31,86,27),fill='#d7aa8d',width=2)
  d.line((16,59,21+n,57),fill='#bfa898',width=2)
 elif p=='hit':
  d.line((42,19,48,25,44,32),fill='#cd9b80',width=2)
  d.line((18,10,13,6),fill='#e7bd78',width=2)
 # Rope-like whip tail, real tail tuft.
 d.line((14,31+low,7,23+low,6,13+low),fill='#342b32',width=3)
 d.ellipse((3,9+low,9,17+low),fill='#1c2028')
 if p=='alert':
  d.line((84,22,89,13),fill='#f3dfb5',width=2)
 if p=='hit':
  d.line((56,13,52,7),fill='#d7b77c',width=2)
 if p=='defeated':
  # Draw a distinct prone silhouette aligned to the same floor.
  flat=im.crop((3,8,89,61)).resize((86,37),Image.Resampling.NEAREST)
  down=Image.new('RGBA',(90,64))
  down.alpha_composite(flat,(2,24))
  im=down
 return im
def runner(p,n):
 im=Image.new('RGBA',(52,70));d=ImageDraw.Draw(im)
 active=p in ('run','attack')
 swing=(-5,0,5,0)[n] if active else 0
 crouch=7 if p=='defeated' else 3 if p=='hit' else 0
 # Feet and legs have distinct front/back planes.
 for x,shift,shade in ((18,swing,'#d5d7d8'),(29,-swing,'#f7f6eb')):
  d.polygon([(x-4,40+crouch),(x+4,40+crouch),(x+4+shift,57+crouch),
             (x-2+shift,61+crouch),(x-7+shift,58+crouch)],
            fill=shade,outline='#707d8c')
  d.polygon([(x-7+shift,57+crouch),(x+4+shift,57+crouch),
             (x+8+shift,61+crouch),(x-7+shift,62+crouch)],
            fill='#414b5b')
 # White shirt with collar, side facets, cinched red sash.
 d.polygon([(16,22+crouch),(23,19+crouch),(32,21+crouch),
    (38,27+crouch),(34,43+crouch),(15,43+crouch),(12,29+crouch)],
   fill='#eee8d8',outline='#777987')
 d.polygon([(16,25+crouch),(22,22+crouch),(21,37+crouch),
             (16,40+crouch)],fill='#ffffff')
 d.polygon([(28,22+crouch),(35,25+crouch),(34,39+crouch),
             (29,41+crouch)],fill='#c0ced4')
 d.polygon([(13,38+crouch),(36,38+crouch),(37,42+crouch),
             (13,43+crouch)],fill='#c42c3f')
 d.polygon([(31,41+crouch),(39,42+crouch),(42,47+crouch),
             (38,50+crouch),(32,45+crouch)],fill='#9e1833')
 # Arms articulated for running / glancing back.
 lift=(-4,1,4,0)[n] if active else 0
 d.polygon([(13,25+crouch),(8,29+crouch),(7,42+crouch+lift),
             (11,45+crouch+lift),(16,33+crouch)],
             fill='#e3c0a0',outline='#876f67')
 d.polygon([(36,26+crouch),(42,31+crouch),(43,39+crouch-lift),
            (39,43+crouch-lift),(31,33+crouch)],
            fill='#e8c4a2',outline='#816a64')
 # Organic human head: hair/ear/nose/jaw/beard rather than rectangular block.
 d.polygon([(19,9+crouch),(25,6+crouch),(34,9+crouch),
   (38,15+crouch),(35,23+crouch),(28,27+crouch),
   (21,23+crouch),(17,16+crouch)],fill='#e8bc94',outline='#835f55')
 d.polygon([(17,15+crouch),(18,8+crouch),(23,5+crouch),
   (32,5+crouch),(37,11+crouch),(33,12+crouch),
   (27,10+crouch),(20,14+crouch)],fill='#503837')
 d.polygon([(29,20+crouch),(36,21+crouch),(32,26+crouch),
   (25,25+crouch)],fill='#77493e')
 d.point((31,16+crouch),fill='#252d36')
 d.polygon([(35,16+crouch),(40,18+crouch),(35,20+crouch)],
          fill='#c99575')
 # Human proportions and clothing planes: replace the flat whites
 # with directional leg seams, shirt folds, sleeve cuffs and face contour.
 d.line((16,30+crouch,19,40+crouch),fill='#a8b8bd',width=2)
 d.line((31,28+crouch,31,38+crouch),fill='#fbfaf2',width=2)
 d.line((21,23+crouch,25,29+crouch,29,24+crouch),
        fill='#fffdfa',width=1)
 d.polygon([(15,35+crouch),(18,33+crouch),(20,39+crouch),
            (17,42+crouch)],fill='#f7f4e8')
 for lx,shift in ((18,swing),(29,-swing)):
  d.line((lx-3,45+crouch,lx-2+shift,54+crouch),
         fill='#a0acb5',width=2)
  d.line((lx+1+shift,56+crouch,lx+5+shift,58+crouch),
         fill='#f9faf4',width=1)
 # Hair clusters and sideburn / eyebrow are not a plain rectangle.
 d.polygon([(19,12+crouch),(23,7+crouch),(29,6+crouch),
            (35,10+crouch),(30,11+crouch),(25,10+crouch)],
           fill='#70524b')
 d.line((29,14+crouch,34,14+crouch),fill='#62413e',width=1)
 d.point((32,16+crouch),fill='#1c2e35')
 d.line((29,23+crouch,34,22+crouch),fill='#5f3535',width=1)
 d.line((25,26+crouch,29,29+crouch),fill='#d4a784',width=1)
 d.line((11,32+crouch,9,41+crouch),fill='#d99f82',width=2)
 d.line((39,32+crouch,41,39+crouch),fill='#f6d2ac',width=2)
 if p=='alert':
  # He checks over his shoulder rather than staring forward forever.
  d.line((22,13,18,15),fill='#4b3434',width=2)
  d.point((21,18),fill='#29333a')
  d.arc((16,12,23,20),180,330,fill='#c68e74',width=1)
 elif p=='run':
  # Bent elbows and diagonal momentum lines, alternating per frame.
  d.line((8,34+(-3,0,3,0)[n],11,28),fill='#f6caa2',width=2)
  d.line((43,37+(3,0,-3,0)[n],40,30),fill='#a47a66',width=2)
 elif p=='attack':
  d.line((40,31,45,27,47,24),fill='#f1c59e',width=3)
 elif p=='hit':
  d.line((12,22,8,17),fill='#c79783',width=2)
 # Red scarf and moving tail with correct cloth layers.
 d.polygon([(18,24+crouch),(29,25+crouch),(36,23+crouch),
   (33,29+crouch),(23,30+crouch)],fill='#b51c35')
 d.polygon([(33,25+crouch),(39+n%3,28+crouch),
    (42+n%3,36+crouch),(36,34+crouch)],fill='#a91731')
 if p=='hit':d.line((11,14,5,10),fill='#e8ca99',width=2)
 if p=='defeated':
  # Fallen runner, not a standing runner with a line underneath.
  rotated=im.rotate(72,resample=Image.Resampling.NEAREST,expand=True)
  rotated.thumbnail((48,31),resample=Image.Resampling.NEAREST)
  down=Image.new('RGBA',(52,70))
  down.alpha_composite(rotated,((52-rotated.width)//2,63-rotated.height))
  im=down
 return im
for kind,cell,draw in [('estafeta_bull',(90,64),bull),('sanfermin_runner',(52,70),runner)]:
 if kind=='sanfermin_runner':
  from build_approved_enemy_art import build
  build(kind)
  continue
 if kind=='estafeta_bull':
  from install_illustrated_enemy_candidates import install
  install(kind)
  continue
 w,h=cell
 atlas=Image.new('RGBA',(w*S*4,h*S*len(POSES)))
 for row,pose in enumerate(POSES):
  for col in range(4):
   atlas.alpha_composite(outline(draw(pose,col)),(col*w*S,row*h*S))
 path=OUT/f'{kind}_atlas.png';atlas.save(path,optimize=True)
 (OUT/f'{kind}_manifest.json').write_text(json.dumps({
  'id':kind,'cell':[w*S,h*S],'columns':4,'rows':len(POSES),
  'poses':POSES,'art_status':'candidate_requires_real_flutter_review',
  'sha256':hashlib.sha256(path.read_bytes()).hexdigest()},indent=2))
 print(path)
