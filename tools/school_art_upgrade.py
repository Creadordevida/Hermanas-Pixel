"""Build REAL runtime PNGs for chapter 7: detailed hall, ordinary classroom, computer lab.
No baked heroes, enemies, coins or HUD. All three share consistent 390px feet ground.
Uses original pixel-art architectural backdrop from project's existing school resource.
"""
from PIL import Image,ImageDraw,ImageFont,ImageFilter
from pathlib import Path
import numpy as np,random,math
R=Path(__file__).resolve().parents[1]/'assets/images/scenes';W,H=1320,480
# Architectural upper from the pixel-art school source already in project.
original=Image.open(R/'school.png').convert('RGB'); upper=original.crop((0,0,W,287))
random.seed(9036)
font_file='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'

def marble_floor():
    # Colored pixel grain / natural marble veining, unlike the rejected striped floor.
    rng=np.random.default_rng(1979)
    h=H-286
    y,x=np.mgrid[:h,:W]
    cloud=rng.normal(0,1,(h//6+2,W//6+2))
    base=Image.fromarray(np.uint8(np.clip(cloud*18+127,0,255))).resize((W,h),Image.Resampling.BILINEAR)
    arr=np.asarray(base).astype(float)-127
    coarse=rng.normal(0,2.2,(h,W))
    light=9*np.sin(x/W*math.pi*1.4+0.2)+6*np.cos(y/70+1)+arr*.23+coarse
    shaded=np.empty((h,W,3),dtype=np.uint8)
    for c,v in enumerate((188,169,150)):
        shaded[:,:,c]=np.uint8(np.clip(v+light+(c-1)*3,0,255))
    im=Image.fromarray(shaded,'RGB')
    d=ImageDraw.Draw(im,'RGBA')
    # Dark skirting, edge shadow then perspective-aware grout lines.
    d.rectangle((0,0,W,13),fill=(79,57,52,255))
    d.line((0,0,W,0),fill=(238,208,161,255),width=3)
    d.line((0,10,W,10),fill=(137,103,82,220),width=2)
    # Rectangular high-resolution in-world tiled floor: 4 rows with soft specular glints.
    for yy in (24,61,108,162):
        d.line((0,yy,W,yy),fill=(85,70,66,85),width=2)
        d.line((0,yy+3,W,yy+3),fill=(248,225,186,50),width=1)
    for row,(start,step,depth) in enumerate([(18,116,24),(45,121,61),(65,137,108),(0,162,162)]):
        for xx in range(start-160,W+160,step):
            d.line((xx,depth,xx-8-(row*4),[61,108,162,h-1][row]),fill=(89,70,67,72),width=2)
            if row<3:d.line((xx+2,depth,xx-6-row*4, [61,108,162,h-1][row]),fill=(250,227,192,54))
    # Grounding shadows of furniture and subtle soft window reflections.
    for x0 in range(75,W,264):
        for yy in (65,115,160):
            x1=x0-13+(yy//4)
            d.line((x1,yy,x1+28,yy+3),fill=(255,236,195,37),width=3)
    return im
floor=marble_floor()

def draw_plants(d,x,y):
    # layered foliage and ceramic pot in the original 16-bit warm light.
    d.ellipse((x-24,y-9,x+26,y+2),fill='#544e45')
    d.polygon([(x-14,y),(x+15,y),(x+10,y+29),(x-11,y+29)],fill='#b96d4c',outline='#613b33')
    d.line((x-8,y+4,x-6,y+23),fill='#e2ad70',width=3)
    for j in range(14):
        xx=x+random.randrange(-32,34);yy=y-random.randrange(30,74)
        d.polygon([(x,y+2),(xx-10,yy+7),(xx+4,yy-8),(xx+12,yy+12)],fill=random.choice(['#276c4f','#33875d','#4c935e','#77ad6a']),outline='#214a41')
        d.line((xx-4,yy+6,xx+1,yy+1),fill='#aed37c',width=2)

def draw_desk(d,x,y,computer=False):
    # shadow, sturdy polished wood, readable structure and proper floor contact.
    d.ellipse((x-4,y+70,x+153,y+82),fill='#715a4c')
    d.polygon([(x+18,y+13),(x+28,y+19),(x+29,y+71),(x+19,y+71)],fill='#5c3c32',outline='#32262c')
    d.polygon([(x+117,y+18),(x+126,y+15),(x+132,y+69),(x+121,y+71)],fill='#6a4236',outline='#3a2e2a')
    d.polygon([(x-1,y+10),(x+136,y+10),(x+146,y+24),(x+11,y+27)],fill='#926249',outline='#48352e')
    d.polygon([(x-3,y+4),(x+130,y+4),(x+141,y+15),(x+8,y+16)],fill='#c78b56',outline='#654839')
    d.line((x+7,y+7,x+124,y+7),fill='#f0c18b',width=2)
    d.line((x+17,y+22,x+126,y+20),fill='#442d2b',width=2)
    d.rectangle((x+28,y+28,x+116,y+44),fill='#71513e',outline='#3f302e')
    d.line((x+30,y+30,x+112,y+30),fill='#b88a5b',width=2)
    if computer:
        # Retro early-2000s PC set, high-contrast readable even scaled down.
        d.polygon([(x+48,y-76),(x+107,y-76),(x+111,y-18),(x+42,y-18)],fill='#24374b',outline='#0b1928')
        d.rectangle((x+49,y-69,x+105,y-29),fill='#3485a8',outline='#b1c4cd',width=2)
        d.polygon([(x+51,y-67),(x+75,y-67),(x+54,y-30)],fill='#72b0be')
        d.line((x+60,y-50,x+91,y-50),fill='#d8e6a4',width=2)
        d.line((x+60,y-43,x+87,y-43),fill='#a8d2ca',width=2)
        d.polygon([(x+69,y-17),(x+84,y-17),(x+86,y+2),(x+65,y+2)],fill='#758494')
        d.polygon([(x+29,y+0),(x+112,y+0),(x+127,y+5),(x+21,y+7)],fill='#c6c4b9',outline='#525a69')
        for ky in range(y+3,y+6):
            for kx in range(x+36,x+109,8):
                d.line((kx,ky,kx+3,ky),fill='#515e6c')
        d.ellipse((x+127,y+1,x+139,y+8),fill='#dad7c5',outline='#79818c')
    else:
        # Book, exercise notebook and pencil (school learning identity).
        d.polygon([(x+34,y-10),(x+87,y-10),(x+97,y+4),(x+29,y+4)],fill='#f2e4c8',outline='#785846')
        d.line((x+37,y-8,x+82,y-8),fill='#bf955a',width=2)
        d.polygon([(x+83,y-15),(x+94,y-15),(x+95,y+4),(x+84,y+4)],fill='#24667b',outline='#1b354b')
        d.line((x+94,y-14,x+110,y+3),fill='#d4ae53',width=3)

def draw_bookshelf(d,x,y):
    d.rectangle((x,y,x+128,y+198),fill='#8e6449',outline='#4b352e',width=5)
    d.line((x+12,y+3,x+12,y+194),fill='#cc9870',width=3)
    for row in range(3):
        sy=y+10+row*60
        d.rectangle((x+8,sy+47,x+119,sy+53),fill='#51362e',outline='#c1945e')
        for j in range(8):
            xx=x+13+j*13;hh=random.randrange(29,43)
            d.rectangle((xx,sy+45-hh,xx+9,sy+46),fill=random.choice(['#344e77','#b85a50','#d2a655','#638b7b','#7e5f8d']),outline='#3c3341')
            d.line((xx+3,sy+50-hh,xx+3,sy+42),fill='#e1bc91',width=1)

def make(mode):
    im=Image.new('RGB',(W,H))
    im.paste(upper,(0,0))
    im.paste(floor,(0,286))
    d=ImageDraw.Draw(im)
    # Keep wall/floor transition consistent in every area.
    d.rectangle((0,279,W,290),fill='#765344')
    d.line((0,278,W,278),fill='#d9b48e',width=3)
    d.line((0,289,W,289),fill='#382e35',width=2)
    if mode=='hall':
        # lockers/windows source remains intact, add contextual signs and details.
        draw_bookshelf(d,572,80)
        font=ImageFont.truetype(font_file,22)
        d.rounded_rectangle((586,14,741,59),radius=6,fill='#173a62',outline='#e2c37d',width=3)
        d.text((603,22),'BIBLIOTECA',font=font,fill='#efe2ba')
        draw_plants(d,323,309);draw_plants(d,952,314)
        d.rounded_rectangle((768,235,918,280),radius=4,fill='#3d526e',outline='#dfad65',width=3)
        d.text((787,240),'AULAS  →',font=font,fill='#fff3d0')
        # blue bookcase on wall and water dispenser, useful recognisable school props.
        d.rectangle((1150,186,1205,272),fill='#526d88',outline='#263c53',width=4)
        d.ellipse((1164,171,1191,204),fill='#79c9da',outline='#22566b',width=3)
        d.rectangle((1167,226,1190,234),fill='#dce2df')
    else:
        # Differentiate classrooms from hallway: detailed noticeboard/blackboard central.
        d.rectangle((340,42,1000,251),fill='#825842',outline='#392e30',width=8)
        d.rectangle((353,54,987,238),fill=('#174f4a' if mode=='classroom' else '#244c69'),outline='#e6c78e',width=3)
        d.line((356,240,989,240),fill='#c59c62',width=4)
        d.polygon([(366,57),(520,57),(386,231)],fill=('#236b60' if mode=='classroom' else '#285f7a'))
        if mode=='classroom':
            font=ImageFont.truetype(font_file,27)
            d.text((505,76),'MATEMÁTICAS',font=font,fill='#d4e8d5')
            d.line((420,126,903,126),fill='#b7d1c9',width=2)
            d.text((465,153),'2 + 3 = 5',font=font,fill='#e6eac2')
            d.text((704,156),'a² + b² = c²',font=ImageFont.truetype(font_file,18),fill='#c8dce1')
            for yline in [201,213]:d.line((458,yline,863,yline),fill='#96c6ad',width=2)
            draw_bookshelf(d,1075,72)
        else:
            font=ImageFont.truetype(font_file,28)
            d.text((458,70),'INFORMÁTICA',font=font,fill='#d6edf5')
            d.rounded_rectangle((490,126,842,204),radius=5,fill='#172b42',outline='#8db1c5',width=3)
            d.text((511,136),'C:\\> APRENDER',font=ImageFont.truetype(font_file,21),fill='#69e4b9')
            d.text((521,169),'01001010  101101',font=ImageFont.truetype(font_file,14),fill='#c2edc5')
            d.rectangle((1051,75,1205,263),fill='#424e60',outline='#202d41',width=6)
            for yy in (104,155,207):
                d.rectangle((1064,yy,1188,yy+33),fill='#243348',outline='#8499a6',width=2)
                d.ellipse((1170,yy+10,1180,yy+19),fill='#79c0b1')
        # desks are behind the playable character at ground line 390.
        for dx,dy in [(66,275),(396,281),(857,272)]:
            draw_desk(d,dx,dy,mode=='computers')
        draw_plants(d,1230,315)
    # finite wave of warm light across floor, consistent with same ceiling/windows.
    im.save(R/('school.png' if mode=='hall' else 'school_'+mode+'.png'))
for key in ['hall','classroom','computers']:make(key)
print('School art finalized: detailed hallway, classroom and computer lab; assets are loaded directly by the Flutter game.')
