"""Extrae fotogramas REALES de las hojas artísticas aprobadas.

No genera ropa por recoloreado. Requiere rutas de origen explícitas porque
no se incluyen fuentes publicitarias/artísticas en el APK compilado.

Uso: python tools/integrate_approved_outfits.py <miren_aprobada.png> <sara_aprobada.png>
"""
from pathlib import Path
import sys, hashlib, json
import numpy as np
from PIL import Image, ImageOps, ImageDraw, ImageFont
from scipy import ndimage as ndi

HERE=Path(__file__).resolve().parent.parent
OUT=HERE/'assets/images/outfits'
QA=HERE/'qa/uniformes'
OUT.mkdir(parents=True, exist_ok=True)
QA.mkdir(parents=True, exist_ok=True)


def extract_sheet(path, role, bg, min_area):
    arr=np.asarray(Image.open(path).convert('RGB')).astype(np.int16)
    dist=np.linalg.norm(arr-np.asarray(bg,dtype=np.int16),axis=2)
    fg=dist>32
    labels,n=ndi.label(fg)
    objects=ndi.find_objects(labels)
    candidates=[]
    for i,sl in enumerate(objects,1):
        if sl is None: continue
        region=labels[sl]==i
        area=int(np.count_nonzero(region))
        if area < min_area: continue
        ys,xs=sl
        candidates.append({'label':i,'area':area,'bounds':[xs.start,ys.start,xs.stop,ys.stop]})
    if len(candidates)!=5:
        raise RuntimeError(f'{role}: se esperaban exactamente 5 siluetas; encontrados {len(candidates)}: {candidates}')
    # Miren: 3 en fila superior y 2 inferior. Sara: 5 en fila.
    if role=='futbolista':
        candidates.sort(key=lambda c: (0 if c['bounds'][1]<300 else 1,c['bounds'][0]))
    else:
        candidates.sort(key=lambda c:c['bounds'][0])
    names = ['idle_0','walk_0','walk_1','jump_0','attack_0']
    if role=='bailarina':
        # La quinta pose (brazos extendidos) llega al borde de la hoja.
        # Se reconstruye SOLO la mano derecha para evitar un brazo cortado.
        names=['idle_0','walk_0','walk_1','jump_0','attack_0']
    entries=[]
    for item,name in zip(candidates,names):
        x0,y0,x1,y1=item['bounds']
        pad=2
        x0=max(0,x0-pad);x1=min(arr.shape[1],x1+pad)
        y0=max(0,y0-pad);y1=min(arr.shape[0],y1+pad)
        one=(labels[y0:y1,x0:x1] == item['label'])
        # Eliminar posibles puntos interiores del fondo y conservar el cuerpo
        # con sus zonas oscuras (que tienen bajo contraste frente al azul).
        one=ndi.binary_fill_holes(one)
        alpha=np.where(one,255,0).astype('uint8')
        # Recuperar antialias del borde de 1px sin fondo del poster.
        border=ndi.binary_dilation(one,iterations=1) & ~one
        local_dist=dist[y0:y1,x0:x1]
        alpha[border]=np.clip((local_dist[border]-13)*255/24,0,192).astype('uint8')
        rgba=np.dstack([arr[y0:y1,x0:x1].astype('uint8'),alpha])
        # Descontaminar el borde: recuperar el color del contorno oscuro en
        # vez de dejar una franja azul del fondo ilustrado.
        q=(alpha>0)&(alpha<255)
        if q.any():
            aa=alpha[q].astype(float)/255
            rgb=rgba[:,:,:3].astype(float)
            b=np.array(bg)
            rgb[q]=np.clip((rgb[q]-(1-aa[:,None])*b)/aa[:,None],0,255)
            rgba[:,:,:3]=rgb.astype('uint8')
        rgba[alpha==0,:3]=0
        pic=Image.fromarray(rgba,'RGBA')
        # Canvas con borde de seguridad, y coordenadas de pies calculables.
        pic=ImageOps.expand(pic, border=(4,4,4,4), fill=(0,0,0,0))
        if role=='bailarina' and name=='attack_0':
            # El brazo extendido llega al borde DERECHO del póster original.
            # Completar únicamente el puño (24x12 px), conservando todos los
            # demás píxeles del diseño aprobado; la reparación es visible y
            # revisable por separado, no se finge extracción literal.
            iw,ih=pic.size
            fixed=Image.new('RGBA',(iw+26,ih),(0,0,0,0))
            fixed.alpha_composite(pic)
            draw=ImageDraw.Draw(fixed)
            yy=660-y0+4
            draw.polygon([(iw-10,yy-5),(iw+10,yy-8),(iw+19,yy-5),
                          (iw+24,yy-1),(iw+23,yy+5),(iw+15,yy+9),
                          (iw-6,yy+7)],fill=(41,16,29,255))
            draw.polygon([(iw-8,yy-3),(iw+10,yy-5),(iw+17,yy-3),
                          (iw+21,yy),(iw+19,yy+4),(iw+12,yy+6),
                          (iw-8,yy+4)],fill=(229,129,82,255))
            draw.line([(iw-4,yy-2),(iw+12,yy-3),(iw+17,yy-1)],
                      fill=(255,192,136,255),width=3)
            pic=fixed
        target=OUT/f'{role}_{name}.png'
        pic.save(target,optimize=True)
        entries.append({'name':name,'path':str(target.relative_to(HERE)),'size':list(pic.size),
             'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),
             'bbox_original':[x0,y0,x1,y1], 'source':str(path),
             'manual_repair': 'mano derecha extendida en borde de hoja' if role=='bailarina' and name=='attack_0' else None})
    return entries


def make_contact():
    W=1320; H=640
    checker=Image.new('RGBA',(W,H),(236,239,243,255))
    d=ImageDraw.Draw(checker)
    for y in range(0,H,20):
        for x in range(0,W,20):
            if ((x+y)//20)%2: d.rectangle((x,y,x+19,y+19),fill=(209,216,224,255))
    # Vista con transparencia sobre cuadriculado; assets exactos, no mockups
    labels=['ESPERA','PASO 1','PASO 2','SALTO','ATAQUE']
    for row,role in enumerate(('futbolista','bailarina')):
        d.text((15,row*318+8),'MIREN - fútbol, ojos marrones' if row==0 else 'SARA - danza, ojos verdes',fill=(23,35,57))
        for i,name in enumerate(['idle_0','walk_0','walk_1','jump_0','attack_0']):
            im=Image.open(OUT/f'{role}_{name}.png').convert('RGBA')
            scale=min(228/im.width,232/im.height)
            im=im.resize((max(1,round(im.width*scale)),max(1,round(im.height*scale))),Image.Resampling.LANCZOS)
            px=i*260+130-im.width//2; py=row*318+42+232-im.height
            checker.alpha_composite(im,(px,py))
            d.text((i*260+70,row*318+287),labels[i],fill=(30,40,55))
    target=QA/'SPRITES_REALES_TRANSPARENTES.png'
    checker.convert('RGB').save(target)
    return str(target)

if __name__=='__main__':
    if len(sys.argv)!=3:
        raise SystemExit(__doc__)
    miren=Path(sys.argv[1]);sara=Path(sys.argv[2])
    all_entries={'futbolista':extract_sheet(miren,'futbolista',(22,51,72),20000),
        'bailarina':extract_sheet(sara,'bailarina',(28,51,69),20000)}
    (QA/'MANIFIESTO_ORIGEN_Y_POSES.json').write_text(json.dumps(all_entries,indent=2,ensure_ascii=False))
    print(make_contact())
