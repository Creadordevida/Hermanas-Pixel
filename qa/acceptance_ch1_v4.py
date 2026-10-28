"""Capitulo 1 V5: impide declarar listo algo que solo pasa Python.
No integra el mundo experimental por defecto ni crea APK/ZIP.
"""
from pathlib import Path
import json,sys,hashlib
from ch1_world_v4_reference import LANDMARKS,LANDMARK_WIDTH,PROPS,PROP_RECTS,LANDMARK_ENDS,ROOT,prop_is_safe
from visual_audit_v5 import seam_info


def verify():
    checks=[]
    expected=json.loads((ROOT/'qa/ch1_legacy_art_sha256.json').read_text())
    art_ok=all(hashlib.sha256((ROOT/p).read_bytes()).hexdigest()==digest
               for p,digest in expected.items())
    checks.append({'check':'Cuatro ilustraciones aprobadas intactas (SHA256)',
                   'passed':art_ok,'type':'hard'})
    checks.append({'check':'Siete pinturas fisicas con escala uniforme',
                   'passed':len(LANDMARKS)==7 and all(LANDMARK_WIDTH[n]>0 for n,*_ in LANDMARKS),
                   'type':'hard'})
    boxes_ok=all(prop_is_safe(x,h*PROP_RECTS[i][2]/PROP_RECTS[i][3]) for _,x,i,h in PROPS)
    checks.append({'check':'Arboles y objetos no invaden las ilustraciones',
                   'passed':boxes_ok,'type':'hard'})
    seams=[seam_info(n,x+LANDMARK_WIDTH[n]) for n,x,*_ in LANDMARKS]
    failures=[s for s in seams if s['jump_mean_rgb']>35]
    checks.append({'check':'Siete salidas de ilustraciones sin corte artificial',
                   'passed':not failures,'type':'visual','failed_count':len(failures),
                   'seams':seams,'threshold_rgb_jump':35,
                   'warning':'Los saltos RGB son indicio, no sustituyen evaluacion artistica'})
    checks.append({'check':'Recorrido completo aprobado por revision artistica',
                   'passed':False,'type':'visual',
                   'reason':'Montaje de 111 camaras muestra tramos vacios y composicion generica'})
    checks.append({'check':'Flutter real ejecutado y pruebas Dart superadas',
                   'passed':False,'type':'runtime',
                   'reason':'Flutter SDK no disponible en este entorno; CI solo preparado'})
    checks.append({'check':'Gameplay Android final comprobado',
                   'passed':False,'type':'runtime',
                   'reason':'No hay ejecucion Android del motor experimental'})
    result={'name':'Hermanas Pixel Capitulo 1 V5',
            'status':'PASS' if all(c['passed'] for c in checks) else 'BLOCKED',
            'checks':checks,'zip_permitted':False,
            'integration_enabled_by_default':False}
    out=ROOT/'qa/ch1_world_v4_previews/PUERTA_ENTREGA.json'
    out.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    return result

if __name__=='__main__':
    result=verify()
    print(json.dumps(result,ensure_ascii=False,indent=2))
    sys.exit(0 if result['status']=='PASS' else 2)
