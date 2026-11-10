"""Generate a review contact sheet for all 24 goalkeeper poses.

Damaged PNGs are decoded only for diagnostic copies; this does not approve them.
Outputs one contact sheet plus a JSON report, never writes game assets.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFile
import json

ROOT=Path("qa/goalkeeper_rebuild_20261109")
OUT=ROOT/"diagnostic_recovery"
OUT.mkdir(exist_ok=True)
NAMES=(
"ready","idle_shift_a","idle_shift_b","idle_shift_c",
"shuffle","shuffle_step_a","shuffle_step_b","shuffle_step_c",
"warning","warning_crouch","warning_reach","warning_extend",
"dive","dive_extension","dive_launch","dive_full",
"hurt","hurt_recoil","hurt_side","hurt_recover",
"defeat_knee","defeat_hands","defeat_side","defeated")
W,H=300,260
sheet=Image.new("RGB",(4*W,6*H),(35,38,43))
draw=ImageDraw.Draw(sheet)
records=[]
for i,name in enumerate(NAMES):
    path=ROOT/f"pose_{name}_rgba.png"
    status="valid"
    try:
        with Image.open(path) as source:
            im=source.convert("RGBA")
            im.load()
    except Exception as error:
        status="damaged/recovered-preview"
        recovered=OUT/path.name
        if not recovered.exists():
            ImageFile.LOAD_TRUNCATED_IMAGES=True
            try:
                with Image.open(path) as source:
                    im=source.convert("RGBA")
                    im.load()
                im.save(recovered)
            finally:
                ImageFile.LOAD_TRUNCATED_IMAGES=False
        else:
            with Image.open(recovered) as source:
                im=source.convert("RGBA")
                im.load()
    x=(i%4)*W
    y=(i//4)*H
    # Two checkerboard tones to expose alpha halos.
    bg=Image.new("RGBA",(W-12,H-42),(85,100,115,255))
    bd=ImageDraw.Draw(bg)
    for yy in range(0,bg.height,20):
        for xx in range(0,bg.width,20):
            if (xx//20+yy//20)%2==0:
                bd.rectangle((xx,yy,xx+19,yy+19),fill=(185,195,202,255))
    alpha=im.getchannel("A")
    bbox=alpha.point(lambda a:255 if a>=128 else 0).getbbox()
    if bbox:
        im=im.crop(bbox)
    im.thumbnail((W-26,H-56),Image.Resampling.NEAREST)
    bg.alpha_composite(im,((bg.width-im.width)//2,(bg.height-im.height)//2))
    sheet.paste(bg.convert("RGB"),(x+6,y+6))
    draw.text((x+8,y+H-30),f"{i:02d} {name}",fill=(255,255,255))
    if status!="valid":
        draw.rectangle((x+2,y+2,x+W-3,y+H-3),outline=(255,85,65),width=4)
    records.append({"name":name,"status":status,"source_size":list(Image.open(path).size),
                    "alpha_bbox":list(bbox) if bbox else None})
sheet.save(OUT/"goalkeeper_24_pose_review_contact_sheet.png")
(OUT/"visual_review_manifest.json").write_text(json.dumps(records,indent=2)+"\n")
print("GOALKEEPER_REVIEW_SHEET_CREATED; red borders indicate damaged/recovered images")
