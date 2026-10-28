#!/usr/bin/env python3
"""Preview the exact 512px PNG game layer with real Sara+ground sprites."""
from PIL import Image,ImageDraw
from pathlib import Path
import subprocess,math
R=Path(__file__).resolve().parents[1]
T=R/'assets/images/chapter1/ch1_world_tiles'
Q=R/'qa/ch1_rc3_tiles'
W,H=800,450
f=Image.open(R/'assets/images/ground/stage_0.png').convert('RGBA')
a=Image.open(R/'assets/images/frames/bailarina_walk_0.png').convert('RGBA')
b=Image.open(R/'assets/images/frames/bailarina_walk_1.png').convert('RGBA')
a=a.resize((round(a.width*112/a.height),112),Image.Resampling.LANCZOS)
b=b.resize((round(b.width*112/b.height),112),Image.Resampling.LANCZOS)
cache={i:Image.open(T/f'world_{i:03}.png').convert('RGB') for i in range(72)}
def frame(cam,j):
 im=Image.new('RGBA',(W,H),'#4a9bd7')
 first=cam//512
 for idx in range(max(0,first-1),min(71,(cam+800)//512+1)+1):
  im.paste(cache[idx],(idx*512-cam,0))
 for x in range(-(cam%f.width),800,f.width):im.paste(f,(x,380),f)
 sprite=a if j%8<4 else b
 im.paste(sprite,(327-sprite.width//2,390-112),sprite)
 return im.convert('RGB')
vid=Q/'RECORRIDO_RESIDENCIAL_VIDEO_RC3.mp4'
cmd=['ffmpeg','-y','-loglevel','error','-f','rawvideo','-pix_fmt','rgb24',
     '-s','800x450','-r','15','-i','pipe:0','-c:v','libx264','-preset','veryfast',
     '-pix_fmt','yuv420p','-crf','24',str(vid)]
p=subprocess.Popen(cmd,stdin=subprocess.PIPE)
for j in range(180):
 cam=min(35700,j*15)
 p.stdin.write(frame(cam,j).tobytes())
p.stdin.close()
assert p.wait()==0
print(vid)
