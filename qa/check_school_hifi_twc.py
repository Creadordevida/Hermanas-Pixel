#!/usr/bin/env python3
"""Verify actual replacement school PNGs: material, identity, windows, 5 rooms.

No '27 distinct hashes = good art' false positive. Detect stale source,
missing master, incorrect dimensions, walls accidentally transparent,
and old silhouette-school generator still in place.
This is a QA gate, NOT a Flutter screenshot or artistic acceptance.
"""
from __future__ import annotations
import hashlib,io,json,sys,zipfile
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'assets/images/school_hifi/school_five_scenes_master.png'
P=ROOT/'assets/images/interiors_parallax/school'
REPORT=ROOT/'qa/school_hifi_lab/SCHOOL_HIFI_MANIFEST.json'

def verify(strict=False):
    if not ART.is_file():
        if strict:raise AssertionError('Original 5-scene school art must exist in Git')
        print('SKIP: school-hi-fi original not in Git, no fake green art approval')
        return None
    assert REPORT.is_file(),'Generator was not executed'
    assert (ROOT/'assets/images/ground/stage_6_hifi.png').is_file(), 'School-specific clean floor missing'
    d=json.loads(REPORT.read_text(encoding='utf-8'))
    assert d['master_sha256']==hashlib.sha256(ART.read_bytes()).hexdigest()
    assert d['master_sha256']=='4370a461007d4e96bef60da32e827995301f41f7d1662fec9749da739d72bc9b',(
        'Wrong five-room reference image: do not substitute other artwork')
    entries=d['panels']
    # The refined glass is still translucent (alpha 166) and preserves the
    # exact RGB pixels of each approved ZIP source. Old sources use alpha<128.
    threshold=d.get('glass_alpha_threshold',128)
    assert 128<=threshold<=254
    assert tuple(Image.open(ART).size)==(1448,1086)
    assert sum(x['transparent_pixels']>1000 for x in entries)>=15
    assert len(entries)==27
    assert set(x['room'] for x in entries)=={
        'pasillo','taquillas','aula','informatica','biblioteca'}
    plan=[ [0,4,0,4,3,0,4,3,0],
           [1,1,0,1,3,1,1,0,3],
           [2,2,4,2,3,2,2,4,2] ]
    kinds=['pasillo','aula','informatica','biblioteca','taquillas']
    for x in entries:
        assert x['room']==kinds[plan[x['zone']][x['variant']]]
    archive=ROOT/'qa/school_inbox/COLEGIO_REFERENCIA_EXACTA_27_PANELES_Y_VENTANAS_MOVILES.zip'
    refined='glass_alpha_method' in d
    if refined:assert archive.is_file(),'Approved ZIP required for RGB provenance'
    checks=[]
    for e in entries:
        p=P/f"z{e['zone']}_panel_{e['variant']}.png"
        assert p.is_file(),p
        with Image.open(p) as source:
            assert source.size==(880,278) and source.mode=='RGBA'
            rgba=np.asarray(source)
        assert hashlib.sha256(p.read_bytes()).hexdigest()==e['sha256']
        assert (rgba[:,:,3]<threshold).sum()==e['transparent_pixels']
        if refined:
            # The sole permitted alteration is glass opacity: no re-drawn
            # architecture, no substitute colours, no changed master pixels.
            with zipfile.ZipFile(archive) as baseline:
                original=np.asarray(Image.open(io.BytesIO(baseline.read(
                    f'assets/images/interiors_parallax/school/z{e["zone"]}_panel_{e["variant"]}.png'))).convert('RGBA'))
            assert np.array_equal(rgba[:,:,:3],original[:,:,:3]),(
                'User-approved RGB artwork changed',p)
            assert (rgba[:,:,3]<255).sum()>1000 or e['transparent_pixels']==0
        # A corridor may have no window; the chapter-wide count is checked
        # above. Physical baseboards and shared panel seams are never sky.
        # Physical baseboard and both module seams NEVER turn into sky.
        assert np.min(rgba[-10:,:,3])>250,p
        assert np.min(rgba[:,0:8,3])>250,p
        assert np.min(rgba[:,-8:,3])>250,p
        checks.append(p.name)
    src=(ROOT/'lib/main.dart').read_text(encoding='utf-8')
    assert "schoolHifiArtworkEnabled" in src
    assert "TWC_SCHOOL_HIFI_ART" in (ROOT/'lib/interiors_parallax_twc.dart').read_text(encoding='utf-8')
    assert '!schoolHifiArtworkEnabled' in src
    assert 'interior_school_z' in src or 'interiorPanelAssetTWC' in src
    print(f'SCHOOL HIFI SOURCE VERIFIED: {len(checks)} real PNGs, 5 room families')
    print('Remaining mandatory verification: real Flutter render and Android review')
    return checks
if __name__=='__main__':
    verify('--strict' in sys.argv)
