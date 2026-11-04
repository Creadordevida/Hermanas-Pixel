#!/usr/bin/env python3
"""Ayuntamiento RC7: import an exact candidate ZIP without modifying other chapters."""
from pathlib import Path
from PIL import Image
from io import BytesIO
import hashlib,json,sys,zipfile

EXPECTED_ZIP_SHA256='e93b3e0c400fe5d9268299f665eecbca6f5e087255fe5989c00b2d3690a74d1a'
PREFIX='assets/images/ayuntamiento_rc7/'
def sha(b):return hashlib.sha256(b).hexdigest()

def run(root,archive):
    root=Path(root)
    archive=Path(archive)
    if not archive.is_file():raise FileNotFoundError(archive)
    if sha(archive.read_bytes())!=EXPECTED_ZIP_SHA256:
        raise ValueError('Wrong Ayuntamiento ZIP: refusing unknown artwork')
    validated={}
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:raise ValueError('Damaged ZIP')
        manifest=json.loads(z.read(PREFIX+'manifest.json'))
        if (manifest.get('tile_width'),manifest.get('tile_height'),
            manifest.get('tile_count'),manifest.get('world_width'))!=(960,390,39,37440):
            raise ValueError('Incorrect art geometry')
        hall=manifest['town_hall']
        if (hall.get('count'),hall.get('world_x'),hall.get('width'))!=(1,17920,1170):
            raise ValueError('City Hall must appear only once at its designated world x')
        entries=manifest['tiles']
        if len(entries)!=39:raise ValueError('Missing tile entries')
        for i,e in enumerate(entries):
            name=f'ayuntamiento_{i:02d}.webp'
            if (e['tile'],e['filename'],e['world_start'])!=(i,name,i*960):
                raise ValueError('Invalid tile slot')
            data=z.read(PREFIX+name)
            if sha(data)!=e['sha256']:raise ValueError('Pixel hash mismatch: '+name)
            with Image.open(BytesIO(data)) as im:
                if im.size!=(960,390):raise ValueError('Wrong tile dimensions: '+name)
                im.verify()
            validated[PREFIX+name]=data
        hall_data=z.read(PREFIX+'consistorial_unico.webp')
        if sha(hall_data)!=hall['sha256']:raise ValueError('Town hall master altered')
        with Image.open(BytesIO(hall_data)) as im:
            if im.size!=(1170,390):raise ValueError('Wrong town hall dimensions')
            im.verify()
        validated[PREFIX+'consistorial_unico.webp']=hall_data
        validated[PREFIX+'manifest.json']=z.read(PREFIX+'manifest.json')
    # Commit only after verifying everything, no unrelated files.
    for name,data in validated.items():
        dest=root/name;dest.parent.mkdir(parents=True,exist_ok=True)
        dest.write_bytes(data)
    print('AYUNTAMIENTO_RC7_CANDIDATES_IMPORTED: 39 tiles + one unique town hall; visual approval pending')
if __name__=='__main__':
    if len(sys.argv)!=3:raise SystemExit('Usage: import_ayuntamiento_rc7_zip.py ROOT ZIP')
    run(*sys.argv[1:])
