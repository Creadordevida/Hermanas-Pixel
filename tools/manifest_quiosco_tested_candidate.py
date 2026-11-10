#!/usr/bin/env python3
"""Create a provenance manifest for tested Quiosco tiles, without installing them.

Use only after a real StagePainter run has passed and the individual tested
WebP bytes have been compared to the candidate files being promoted.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument('--tiles', type=Path, required=True)
    ap.add_argument('--old-manifest', type=Path, required=True)
    ap.add_argument('--candidate-audit', type=Path, required=True)
    ap.add_argument('--separators-audit', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    previous = json.loads(args.old_manifest.read_text())
    assembly = json.loads(args.candidate_audit.read_text())
    separators = json.loads(args.separators_audit.read_text())
    assert assembly['world_width'] == 37440
    assert assembly['kiosk_world_x'] == 17920
    assert assembly['kiosk_count'] == 1
    placements = [p for p in separators['placements']
                  if p['status'] == 'qa_overlay']
    assert len(placements) == 8
    tiles = []
    hashes = set()
    for n in range(39):
        name = f'quiosco_{n:02d}.webp'
        path = args.tiles / name
        with Image.open(path) as im:
            assert im.size == (960, 390), (name, im.size)
            im.verify()
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        hashes.add(digest)
        tiles.append({'tile': n, 'filename': name, 'world_start': 960*n,
                      'sha256': digest})
    assert len(hashes) == 39, 'Repeated tile bytes'
    source_details = [
        {'part': 'facade_candidate', 'source': record['source'],
         'world_x': record['world_start'], 'crop_x': 0, 'width': 2172}
        for record in assembly['original_sources']
    ]
    assert len(source_details) == len({s['source'] for s in source_details}) == 18
    manifest = {
        'tile_count': 39, 'tile_width': 960, 'tile_height': 390,
        'world_width': 37440, 'landmark': previous['landmark'],
        'tiles': tiles, 'source_details': source_details,
        'separator_placements': placements,
        'stagepainter_verification': {
            'workflow_run': 42680016537,
            'result': 'SUCCESS',
            'screenshots': 64,
            'source_commit': '42f1ed31367485c640146ae48dd64e86e80293a3',
            'artistic_status': 'RC7_PLAYTEST_CANDIDATE_ANDROID_PENDING',
        },
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, ensure_ascii=False,
                                   indent=2) + '\n')
    print('QUIOSCO_TESTED_MANIFEST_OK 39 distinct tiles / 8 separators')


if __name__ == '__main__':
    main()
