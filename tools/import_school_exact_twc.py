#!/usr/bin/env python3
"""Import exactly the accepted 30 school files; reject altered/replaced art.

Only invoked by the school-assets-only GitHub workflow. Never builds Android.
"""
from __future__ import annotations
import hashlib, io, json, sys, zipfile
from pathlib import Path
from PIL import Image

APPROVED_ZIP_SHA='c9579acf7ba154cfaaa31ffd237bacb50d7a723000bbea278f0123008e2dee78'
APPROVED_MASTER_SHA='4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b'
MASTER='assets/images/school_hifi/school_five_scenes_master.png'
FLOOR='assets/images/ground/stage_6_hifi.png'
MANIFEST='qa/school_hifi_lab/SCHOOL_HIFI_MANIFEST.json'
PANEL_PREFIX='assets/images/interiors_parallax/school/'

def sha(data): return hashlib.sha256(data).hexdigest()

def run(root, archive):
    root, archive=Path(root).resolve(),Path(archive)
    if not archive.is_file(): raise FileNotFoundError(archive)
    if sha(archive.read_bytes())!=APPROVED_ZIP_SHA:
        raise ValueError('Wrong ZIP: not the exact approved school artwork')
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None: raise ValueError('ZIP integrity failure')
        manifest=json.loads(z.read(MANIFEST))
        if sha(z.read(MASTER))!=APPROVED_MASTER_SHA:
            raise ValueError('Master PNG SHA does not match accepted artwork')
        if manifest.get('master_sha256')!=APPROVED_MASTER_SHA:
            raise ValueError('Manifest is for a different master')
        entries=manifest.get('panels',[])
        if len(entries)!=27 or len({(x['zone'],x['variant']) for x in entries})!=27:
            raise ValueError('Expected 27 unique school panel slots')
        if set(x['room'] for x in entries)!={
                'pasillo','taquillas','aula','informatica','biblioteca'}:
            raise ValueError('Missing one of the accepted five school scenes')
        expected={MASTER,FLOOR,MANIFEST}
        for x in entries:
            znum,n=x['zone'],x['variant']
            if not (0<=znum<3 and 0<=n<9):
                raise ValueError('Invalid school panel address')
            expected.add(f'{PANEL_PREFIX}z{znum}_panel_{n}.png')
        prepared={}
        for path in sorted(expected):
            data=z.read(path)
            if path.endswith('.png'):
                with Image.open(io.BytesIO(data)) as im: im.verify()
                with Image.open(io.BytesIO(data)) as im:
                    if path.startswith(PANEL_PREFIX) and (
                            im.size!=(880,278) or im.mode!='RGBA'):
                        raise ValueError('Invalid RGBA panel: '+path)
                    if path==MASTER and im.size!=(1448,1086):
                        raise ValueError('Invalid 5-room master size')
                    if path==FLOOR and im.size!=(540,202):
                        raise ValueError('Invalid clean floor size')
            prepared[path]=data
        for x in entries:
            p=f"{PANEL_PREFIX}z{x['zone']}_panel_{x['variant']}.png"
            if sha(prepared[p])!=x['sha256']:
                raise ValueError('Panel SHA mismatch: '+p)
        # Fully checked before any changes. Reject all unrelated ZIP contents.
        for path,data in prepared.items():
            dest=root/path;dest.parent.mkdir(parents=True,exist_ok=True)
            tmp=dest.with_name(dest.name+'.school-verified-tmp')
            tmp.write_bytes(data)
            tmp.replace(dest)
    print('IMPORTED EXACT APPROVED SCHOOL: 27 panels, master, clean floor, hash manifest')
    return sorted(expected)

if __name__=='__main__':
    if len(sys.argv)!=3:
        raise SystemExit('Usage: import_school_exact_twc.py REPO_ROOT ZIP_PATH')
    run(sys.argv[1],sys.argv[2])
