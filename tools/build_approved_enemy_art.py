"""Derive game atlases from user-approved artwork; never redraw characters.
Fixed scale per sheet, explicit row boundaries, native RGB preserved before
nearest-neighbour reduction. Generated poses: none. Alpha cleanup only.
"""
from pathlib import Path
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SPECS={
 'robot':('robot_sheet_candidate.png',[0,270,505,750,990,1245,1536],(144,192),[0,1,2,3,4,5],'30cab23ab53d612c0d34dacb888b9d2404a925eae640000f601a5d37f5eebf85'),
 'sanfermin_runner':('runner_sheet_candidate.png',[0,285,550,815,1090,1340,1536],(156,210),[0,2,1,3,4,5],'16d5b35153ceb5a2317c6c695049598bfc2366fcc3a1e054d2b36912397dd360')}
def build(kind):
 name,ys,cell,order,expected=SPECS[kind]
 src=ROOT/'qa/enemy_art_20261031'/name
 assert hashlib.sha256(src.read_bytes()).hexdigest()==expected,'Approved source changed'
 im=Image.open(src).convert('RGBA')
 frames=[]; rects=[]
 for r in order:
  for c in range(4):
   xs=[0,240,500,800,1024] if kind=='robot' and r==3 else [0,256,512,768,1024]
   box=(xs[c],ys[r],xs[c+1],ys[r+1]); f=im.crop(box)
   # Residual backdrop alpha is near zero; preserve RGB, make pixel edges binary.
   f.putalpha(f.getchannel('A').point(lambda a:255 if a>=128 else 0))
   bb=f.getbbox(); assert bb,'Empty frame'
   frames.append(f.crop(bb));rects.append([box,bb])
 # ONE uniform scale for every frame; never stretch a falling pose to idle height.
 scale=min((cell[0]-8)/max(f.width for f in frames),(cell[1]-8)/max(f.height for f in frames))
 atlas=Image.new('RGBA',(cell[0]*4,cell[1]*6))
 for i,f in enumerate(frames):
  f=f.resize((round(f.width*scale),round(f.height*scale)),Image.Resampling.NEAREST)
  atlas.alpha_composite(f,((i%4)*cell[0]+(cell[0]-f.width)//2,(i//4+1)*cell[1]-f.height))
 out=ROOT/'assets/images/enemies_new';out.mkdir(parents=True,exist_ok=True)
 target=out/(kind+'_atlas.png');atlas.save(target,optimize=True)
 report={'source_sha256':expected,'atlas_sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'cell':cell,'scale':scale,'source_rectangles':rects,'newly_drawn_frames':[],'direction_approved':True,'animation_approved':False,'flutter_verified':False}
 (out/(kind+'_approved_source.json')).write_text(json.dumps(report,indent=2)+'\n')
 print(kind,atlas.size,'scale',scale)
 return target
if __name__=='__main__':
 for kind in SPECS:build(kind)
