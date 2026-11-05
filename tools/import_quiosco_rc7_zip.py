#!/usr/bin/env python3
"""Import ONLY exact Quiosco Plaza del Castillo candidate ZIP after full validation.
This protects existing chapters and makes no artistic approval claims.
"""
from pathlib import Path
from PIL import Image
from io import BytesIO
import hashlib,json,sys,zipfile

EXPECTED_ZIP_SHA256='579be9b94275b22dcc232d69a8304c00bbb459e914c768fa82c57a3ea475f606'
PREFIX='assets/images/quiosco_rc7/'
def sha(data):return hashlib.sha256(data).hexdigest()
def run(root,archive):
    root=Path(root);archive=Path(archive)
    if not archive.is_file():raise FileNotFoundError(archive)
    if sha(archive.read_bytes())!=EXPECTED_ZIP_SHA256:
        raise ValueError('Unexpected Quiosco ZIP bytes: do not bypass verified import')
    output={}
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:raise ValueError('ZIP damaged')
        manifest_data=z.read(PREFIX+'manifest.json')
        m=json.loads(manifest_data)
        if tuple(m.get(x) for x in ('tile_count','tile_width','tile_height','world_width'))!=(39,960,390,37440):
            raise ValueError('Incorrect world geometry')
        kiosk=m['landmark']
        if tuple(kiosk.get(x) for x in ('world_x','width','count'))!=(17920,1170,1):
            raise ValueError('There must be ONE bandstand, at a verified position')
        tiles=m['tiles']
        if len(tiles)!=39:raise ValueError('Incomplete panel set')
        for i,item in enumerate(tiles):
            name=f'quiosco_{i:02d}.webp'
            if (item.get('tile'),item.get('filename'),item.get('world_start'))!=(i,name,i*960):
                raise ValueError('Wrong panel slot')
            raw=z.read(PREFIX+name)
            if sha(raw)!=item['sha256']:raise ValueError('Hash mismatch '+name)
            with Image.open(BytesIO(raw)) as im:
                if im.size!=(960,390):raise ValueError('Incorrect image dimensions')
                im.verify()
            output[PREFIX+name]=raw
        master=z.read(PREFIX+'quiosco_unico.webp')
        if sha(master)!=kiosk['sha256']:raise ValueError('Bandstand original changed')
        with Image.open(BytesIO(master)) as im:
            if im.size!=(1170,390):raise ValueError('Wrong bandstand dimensions')
            im.verify()
        output[PREFIX+'quiosco_unico.webp']=master
        output[PREFIX+'manifest.json']=manifest_data
    for name,data in output.items():
        dest=root/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
    print('QUIOSCO CANDIDATE INTEGRITY VERIFIED: 39 panels + 1 bandstand')
    print('ARTISTIC STATUS: CANDIDATE; NOT YET APPROVED, NOT READY FOR RELEASE')

if __name__=='__main__':
    if len(sys.argv)!=3:raise SystemExit('Usage: import_quiosco_rc7_zip.py ROOT ZIP')
    run(*sys.argv[1:])
