#!/usr/bin/env python3
"""Import dance originals from one verified ZIP, preserving approved bytes."""
import hashlib, json, sys, zipfile
from pathlib import Path

ZIP_SHA = 'd3127c7fbf33ff57a629e9bc05dcec9f38bb2de4adb2b21a38c1b7209ec222a2'
NAMES = ('01_recepcion.png','02_estudio.png','03_escenario.png','04_pasillo.png','05_vestuario.png')
OUT = 'assets/images/interiors_parallax/dance/hifi'

def sha(b): return hashlib.sha256(b).hexdigest()

def main(root, archive):
    root, archive = Path(root).resolve(), Path(archive)
    if sha(archive.read_bytes()) != ZIP_SHA:
        raise ValueError('Not the approved dance ZIP')
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:
            raise ValueError('Corrupt ZIP')
        if set(z.namelist()) != {*NAMES, 'MANIFIESTO.json', 'README.txt'}:
            raise ValueError('Unexpected ZIP members')
        manifest = json.loads(z.read('MANIFIESTO.json'))
        rooms = {x['filename']: x for x in manifest['rooms']}
        if set(rooms) != set(NAMES): raise ValueError('Unexpected room list')
        payload = {}
        for name in NAMES:
            data = z.read(name)
            if sha(data) != rooms[name]['sha256']:
                raise ValueError('SHA mismatch '+name)
            width=int.from_bytes(data[16:20],'big')
            height=int.from_bytes(data[20:24],'big')
            if data[:8] != b'\x89PNG\r\n\x1a\n' or [width,height] != rooms[name]['dimensions']:
                raise ValueError('Invalid PNG geometry '+name)
            payload[name]=data
        for name,data in payload.items():
            dest=root/OUT/name
            dest.parent.mkdir(parents=True,exist_ok=True)
            dest.write_bytes(data)
    print('DANCE APPROVED ZIP IMPORTED EXACTLY: 5/5')

if __name__=='__main__':
    if len(sys.argv)!=3: raise SystemExit('usage: import_dance_exact_twc.py ROOT ZIP')
    main(*sys.argv[1:])
