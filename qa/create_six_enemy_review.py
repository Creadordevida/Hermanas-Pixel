#!/usr/bin/env python3
"""Hoja de revisión REAL de recursos; NO es captura de Flutter ni aprobación.

Uso, sin compilar Android ni ejecutar Actions:
    python3 tools/generate_new_enemy_sprites.py
    python3 tools/generate_navarre_king.py
    python3 tools/generate_estafeta_enemies.py
    python3 qa/create_six_enemy_review.py

Usa exclusivamente PNG reales generados por los seis scripts del juego
y los recursos originales de Miren y Sara. No recrea personajes ni escenas.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"qa"/"art_review"
OUT.mkdir(parents=True,exist_ok=True)
SRC=ROOT/"assets"/"images"/"enemies_new"
HEROES=[("Miren — referencia real",ROOT/"assets/images/futbolista.png"),
        ("Sara — referencia real",ROOT/"assets/images/bailarina.png")]
ENEMIES=[
 ("Toro de Estafeta","estafeta_bull",(270,192)),
 ("Corredor sanferminero","sanfermin_runner",(156,210)),
 ("Rey de Navarra","navarre_king",(168,216)),
 ("Robot de limpieza","robot",(144,192)),
 ("Aficionado rival","supporter",(144,192)),
 ("Turista","tourist",(144,192)),
]
font_path="/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
font=ImageFont.truetype(font_path,22) if Path(font_path).exists() else ImageFont.load_default()
small=ImageFont.truetype(font_path,15) if Path(font_path).exists() else ImageFont.load_default()

W,H=1840,1250
canvas=Image.new("RGB",(W,H),"#181e29")
d=ImageDraw.Draw(canvas)
d.text((25,12),"MIREN Y SARA — COMPARACIÓN CON RECURSOS REALES",font=font,fill="#f5f3ed")
d.text((25,43),"Arte fuente y atlas; NO es una captura del juego. Revisión visual humana OBLIGATORIA.",font=small,fill="#e8b57b")

def plate(img,x,y,w,h):
 a=Image.new("RGBA",(w,h),"#303c4b")
 for xx in range(0,w,14):
  for yy in range(0,h,14):
   if (xx//14+yy//14)%2==0:
    ImageDraw.Draw(a).rectangle((xx,yy,xx+13,yy+13),fill="#354454")
 img=img.convert("RGBA")
 img.thumbnail((w-12,h-12),Image.Resampling.NEAREST)
 a.alpha_composite(img,((w-img.width)//2,h-img.height-7))
 canvas.paste(a.convert("RGB"),(x,y))

for j,(name,path) in enumerate(HEROES):
 if not path.exists():raise FileNotFoundError(path)
 x=30+j*345
 d.text((x,76),name,font=small,fill="#e3edf7")
 plate(Image.open(path),x,104,300,440)

report=[]
for i,(name,kind,(cw,ch)) in enumerate(ENEMIES):
 path=SRC/f"{kind}_atlas.png"
 if not path.exists():raise FileNotFoundError(
  f"Falta {path}; ejecuta primero los generadores locales.")
 atlas=Image.open(path).convert("RGBA")
 assert atlas.size==(cw*4,ch*6),(kind,atlas.size)
 x=745+(i%3)*360
 y=82+(i//3)*520
 d.text((x,y),name,font=small,fill="#f0f4f8")
 d.text((x,y+25),"reposo / alerta / movimiento / ataque / golpe / derrota",
        font=small,fill="#9db6c7")
 # Six actual frames from the atlas, no artwork re-created here.
 for row in range(6):
  frame=atlas.crop((cw*0,ch*row,cw,ch*(row+1)))
  frame.thumbnail((100,150),Image.Resampling.NEAREST)
  plate(frame,x+(row%3)*112,y+51+(row//3)*190,105,163)
  report.append(dict(enemy=kind,pose=row,frame=0,alpha_bbox=
   list(frame.getchannel("A").getbbox() or [])))
d.text((30,580),"REFERENCIAS ORIGINALES: NO ES LA ESCALA EFECTIVA DE GAMEPLAY",
       font=small,fill="#f1bb82")
d.text((30,605),"Proporciones, sombras, telas y anatomía: evaluar visualmente.",
       font=small,fill="#dce4ee")
d.text((30,632),"Los tests automáticos NO aprueban la calidad estética.",
       font=small,fill="#dce4ee")
target=OUT/"seis_enemigos_vs_miren_sara_RECURSOS.png"
canvas.save(target,optimize=True)
(OUT/"metadatos_comparacion.json").write_text(json.dumps(report,indent=2),
                                              encoding="utf-8")
print(f"Hoja real de recursos (no Flutter): {target}")
