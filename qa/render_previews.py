"""STATIC ASSET montage, explicitly not a screenshot of executable Flutter UI."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
A=Path(__file__).resolve().parents[1]/'assets/images'
out=Path(__file__).resolve().parents[1]/'qa'
scenes=['level_pixel.png','level_ayuntamiento.png','level_estafeta.png','level_plaza_castillo.png',
 'scenes/football.png','scenes/ballet.png','scenes/school.png']
heads=['La salida de casa','Ayuntamiento','Estafeta','Plaza del Castillo','Fútbol','Danza','Colegio']
enemy=['dog/idle.png','enemies/statue_0.png','enemies/rat_0.png','enemies/pigeon_0.png',
 'enemies/rival_0.png','enemies/novice_0.png','enemies/teacher_0.png']
prop=['crate.png','crate.png','crate.png','props/planter.png','props/cone.png','props/gym_bench.png','props/backpack.png']
img=Image.new('RGB',(800*2,450*4),'#242b38');d=ImageDraw.Draw(img)
for i in range(7):
 pane=Image.new('RGB',(800,450),'#6daac0');scene=Image.open(A/scenes[i]).convert('RGBA').resize((1230 if i<4 else 1150,400))
 pane.paste(scene,(0,0),scene)
 c=ImageDraw.Draw(pane)
 c.rectangle((0,388,800,450),fill=['#82766a','#82766a','#82766a','#82766a','#47723d','#be8f5c','#a77c54'][i])
 c.rectangle((0,388,800,395),fill='#d8ad6d')
 for j,x in enumerate([240,530]):
  obj=Image.open(A/prop[i]).convert('RGBA');obj.thumbnail((60,45))
  pane.paste(obj,(x,390-obj.height),obj)
  coin=Image.open(A/'coin.png').convert('RGBA').resize((22,22))
  pane.paste(coin,(x+94,318),coin)
 e=Image.open(A/enemy[i]).convert('RGBA');e.thumbnail((100,91))
 pane.paste(e,(540,390-e.height),e)
 r='futbolista' if i!=5 else 'bailarina'
 frame=('outfits/' if i in (4,5) else 'frames/')+f'{r}_idle_0.png'
 who=Image.open(A/frame).convert('RGBA');who.thumbnail((88,115))
 pane.paste(who,(155,390-who.height),who)
 d2=ImageDraw.Draw(pane)
 d2.rectangle((8,9,380,43),fill='#123456');d2.text((19,18),f'{i+1}. {heads[i]} · vista estática',fill='#ffffff')
 img.paste(pane,((i%2)*800,(i//2)*450))
# last panel explicit explanation
f=ImageDraw.Draw(img);f.rectangle((800,1350,1600,1800),fill='#193753');f.text((852,1510),'VISTA PREVIA DE RECURSOS',fill='#f2db79')
f.text((852,1550),'No es una captura del APK.',fill='white');f.text((852,1580),'Sin pruebas de movimiento.',fill='white')
img.save(out/'vista_recursos_090.jpg',quality=90)
print(out/'vista_recursos_090.jpg')
