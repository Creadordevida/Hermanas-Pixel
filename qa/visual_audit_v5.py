"""Strict image-native QA for the experimental world. Never grants Flutter approval.
Separates technical coverage, protected art integrity, photographic seam, and
art-direction manual review. Inspect output, not only metrics.
"""
from pathlib import Path
import sys, json, hashlib, math
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ch1_world_v4_reference as world

OUT=world.ROOT/'qa/ch1_v5_audit'
OUT.mkdir(exist_ok=True)
ART=world.ROOT/'assets/images/chapter1'
W,H=world.W,world.H

def seam_info(name, world_end):
    # Independently inspect image leaving and incoming modular geometry.
    camera=max(0,min(world.STAGE_W-W,world_end-280))
    edge=int(round(world_end-camera))
    frame=world.frame(camera)
    rgb=np.asarray(frame,dtype=np.int16)
    color_step=float(np.abs(rgb[35:325,edge-1]-rgb[35:325,edge]).mean())
    # Also evaluate a five-column band to catch sharp, opaque outlines.
    band=float(np.abs(rgb[35:325,edge-3]-rgb[35:325,edge+3]).mean())
    return {'name':name,'world_edge':round(world_end,2),'camera':round(camera,2),
            'edge_px':edge,'jump_mean_rgb':round(color_step,2),
            'six_pixel_band_mean':round(band,2),'visible':0<edge<W}

def run():
    # Several camera positions around every source end, and critical authored
    # region boundaries. No vertical line drawn onto actual pictures.
    coords=[]
    for i,(name,x,sw,sh) in enumerate(world.LANDMARKS):
        right=x+world.LANDMARK_WIDTH[name]
        coords.extend([right-550,right-380,right-240,right-80,right+80])
    for name,start,end in world.REGIONS:
        coords.extend([start-200,start,end-400,end-200])
    coords.extend([0,1000,2000,5000,8100,11200,13000,17800,20300,23700,29000,32500,35700])
    cameras=sorted(set(int(max(0,min(world.STAGE_W-W,c))) for c in coords))
    # Gallery selectively samples one image from each of seven photo boundaries.
    thumbs=[]
    seams=[]
    for name,x,sw,sh in world.LANDMARKS:
        end=x+world.LANDMARK_WIDTH[name]
        info=seam_info(name,end)
        seams.append(info)
        frame=world.frame(info['camera'])
        thumb=frame.resize((640,360),Image.Resampling.BILINEAR)
        ImageDraw.Draw(thumb).text((8,8),f"{name}  corte x={info['world_edge']:.0f}  salto={info['jump_mean_rgb']:.1f}", fill='white',stroke_width=2,stroke_fill='#101010')
        thumbs.append(thumb)
    contact=Image.new('RGB',(640*2,360*math.ceil(len(thumbs)/2)),'#233047')
    for i,thumb in enumerate(thumbs):contact.paste(thumb,((i%2)*640,(i//2)*360))
    contact.save(OUT/'AUDITORIA_SIETE_BORDES.png',optimize=True)

    # Revisit the actual graphic every few hundred world pixels in geographic
    # order, including every join/zone transition. Use 800x450 thumbnails.
    all_cameras=[]
    for c in range(0,int(world.STAGE_W-W),700):all_cameras.append(c)
    all_cameras.extend(cameras)
    all_cameras=sorted(set(all_cameras))
    strip=Image.new('RGB',(800*4,450*math.ceil(len(all_cameras)/4)),'#182035')
    for i,c in enumerate(all_cameras):
        f=world.frame(c)
        ImageDraw.Draw(f).rounded_rectangle((4,4,245,27),radius=3,fill='#14263b')
        ImageDraw.Draw(f).text((12,10),f"MUNDO {c:5d}  (QA NO APROBADO)",fill='white')
        strip.paste(f,((i%4)*800,(i//4)*450))
    strip.save(OUT/'RECORRIDO_COMPLETO_MUESTREO.png',optimize=True)

    # Measurements are NOT a substitute for artistic evaluation.
    rejected=[x['name'] for x in seams if x['jump_mean_rgb']>35]
    results={
        'stage_units':world.STAGE_W,'camera_samples':len(all_cameras),
        'landmark_count':len(world.LANDMARKS),
        'protected_originals_unchanged': all(
          hashlib.sha256((world.ROOT/p).read_bytes()).hexdigest()==h
          for p,h in json.loads((world.ROOT/'qa/ch1_legacy_art_sha256.json').read_text()).items()),
        'seams':seams, 'seam_jump_heuristic_rejections':rejected,
        'all_seams_artistically_approved':False,
        'flutter_runtime_tested':False,
        'pass':False,
        'notes':['Se revisa un contacto de siete bordes y todo el mundo a intervalos cortos',
        'Ningun indicador numerico da por aprobada una pared cortada',
        'Flutter SDK no disponible; nunca declarar test de motor realizado'],
    }
    (OUT/'AUDITORIA_V5.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
    return results

if __name__=='__main__':
    r=run()
    print(json.dumps({'camera_samples':r['camera_samples'],
            'seam_rejections':r['seam_jump_heuristic_rejections'],
            'fluttter_tested':r['flutter_runtime_tested'],
            'pass':r['pass']},ensure_ascii=False,indent=2))
