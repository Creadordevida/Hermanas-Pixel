#!/usr/bin/env python3
"""Compose eighteen distinct candidate façades into a 37,440px QA panorama.

This is an ART CANDIDATE, never a gameplay screenshot or final visual approval.
The three connectors A/B/C are reproducible pixel-boundary transitions.
No active game asset is overwritten. The unique historic bandstand is inserted
once at its manifest coordinate, preserving the original 1170x390 image.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
WORLD = 37440
HEIGHT = 390
SOURCE_WIDTH = 2172
OVERLAP = 96
KIOSK_X = 17920
NAMES = [
    'teatro', 'poniente', 'comercios', 'galeria', 'oriente',
    'arte_nuevo', 'palacio', 'arcadas_siena', 'hotel_mansarda',
    'galeria_balcones', 'terraza_aristocratica', 'barrio_comercial',
    'cafes_historicos', 'galeria_invierno', 'hotel_rosa',
    'biblioteca', 'mansiones_amarillas', 'palacetes',
]


def source(name: str, work: Path) -> Path:
    if name == 'galeria':
        local = work / 'quiosco_galeria_transicion_2172x390_candidate.webp'
    elif name in ('arte_nuevo', 'palacio'):
        local = work / f'quiosco_fachadas_{name}_2172x390_candidate.webp'
    else:
        local = work / f'quiosco_{name}_2172x390_candidate.webp'
    if local.is_file():
        return local
    remote = ROOT / 'qa/quiosco_inbox' / f'fachadas_{name}_nativas_2172x390_candidate.webp'
    if remote.is_file():
        return remote
    raise FileNotFoundError(f'Missing original candidate {name}: {local}, {remote}')


def best_seam(left: Image.Image, right: Image.Image,
              preferred: int) -> list[int]:
    """Find a low-contrast, slowly winding seam through the 96px overlap.

    This optimizes pixels, not building semantics: every result still requires
    human review, especially incompatible roofs / windows / arch dimensions.
    """
    width = left.width
    a = left.load()
    b = right.load()
    costs = [[0.0]*width for _ in range(HEIGHT)]
    parents = [[0]*width for _ in range(HEIGHT)]
    for y in range(HEIGHT):
        for x in range(8, width-8):
            c = sum(abs(v-w) for v,w in zip(a[x,y], b[x,y])) / 3
            center_penalty = abs(x-preferred)*0.16
            if y == 0:
                costs[y][x] = c + center_penalty
            else:
                choices = range(max(8,x-2), min(width-8,x+3))
                parent = min(choices, key=lambda z: costs[y-1][z] + 0.3*abs(z-x))
                parents[y][x] = parent
                costs[y][x] = c + center_penalty + costs[y-1][parent]
        for x in list(range(8))+list(range(width-8,width)):
            costs[y][x] = float('inf')
    end = min(range(8,width-8), key=lambda x: costs[-1][x])
    path=[end]*HEIGHT
    for y in range(HEIGHT-1,0,-1):
        path[y-1] = parents[y][path[y]]
    return path


def main() -> None:
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('--work', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--order-json', type=Path,
                   help='Optional separately audited ordering of all 18 unique sources')
    args = p.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    names = NAMES
    if args.order_json is not None:
        names = json.loads(args.order_json.read_text())['optimized_order']
        if len(names)!=len(NAMES) or set(names)!=set(NAMES):
            raise ValueError('Optimized order must contain each of 18 sources exactly once')

    art = Image.new('RGB', (WORLD, HEIGHT))
    details = []
    cursor = 0
    for index, name in enumerate(names):
        path = source(name, args.work)
        with Image.open(path) as opened:
            im = opened.convert('RGB')
        if im.size != (SOURCE_WIDTH, HEIGHT):
            raise ValueError(f'{path}: {im.size}, expected 2172x390')
        if index == 0:
            art.paste(im, (0, 0))
            cursor = SOURCE_WIDTH
            details.append({'source': name, 'world_start': 0, 'connector': None})
            continue
        start = cursor - OVERLAP
        connector = 'ABC'[(index - 1) % 3]
        seam = {'A': 32, 'B': 48, 'C': 64}[connector]
        # Architectural join retains one façade on each side. A narrow,
        # feathered seam prevents transparent gaps, but DOES NOT guarantee
        # architectural continuity; mandatory visual StagePainter review.
        if start < WORLD:
            left = art.crop((start, 0, min(cursor, WORLD), HEIGHT))
            available = left.width
            left_pixels = left.load()
            right_pixels = im.load()
            seam_path = best_seam(left, im, seam)
            for y in range(HEIGHT):
                for x in range(available):
                    # Wider blend for sky only; prevent double-exposed walls.
                    if y < 110:
                        alpha = x / max(1, available - 1)
                    else:
                        alpha = max(0.0, min(1.0, (x - seam_path[y] + 5) / 10.0))
                    a = left_pixels[x, y]
                    b = right_pixels[x, y]
                    art.putpixel((start + x, y), tuple(round(v * (1-alpha) + w * alpha)
                                                           for v, w in zip(a, b)))
            end = min(WORLD, start + SOURCE_WIDTH)
            if end > cursor:
                art.paste(im.crop((OVERLAP, 0, OVERLAP + end - cursor, HEIGHT)),
                          (cursor, 0))
        details.append({'source': name, 'world_start': start,
                        'connector': connector, 'overlap': OVERLAP,
                        'seam_center': start + seam,
                        'seam_mode': 'minimum_pixel_error_winding_path'})
        cursor = start + SOURCE_WIDTH

    if cursor < WORLD:
        raise AssertionError(f'World only covered through {cursor}/{WORLD}')
    kiosk_path = ROOT / 'assets/images/quiosco_rc7/quiosco_unico.webp'
    with Image.open(kiosk_path) as k:
        kiosk = k.convert('RGB')
    if kiosk.size != (1170, HEIGHT):
        raise ValueError(f'Unexpected landmark size {kiosk.size}')
    # The kiosk already has a coherent courtyard/background. Its boundaries
    # should NOT be blended over 96px: that double-exposes whole buildings.
    # Use an 8px architectural feather and a 160px gradual paving transition
    # below the building line. This avoids ghosted balconies and avoids a
    # sudden straight seam through the different cobblestone perspectives.
    for x in range(kiosk.width):
        edge = min(x, kiosk.width - 1 - x)
        worldx = KIOSK_X + x
        for y in range(HEIGHT):
            feather = 8.0 + 152.0*max(0.0,min(1.0,(y-285)/65.0))
            alpha = min(1.0, edge / feather)
            a = art.getpixel((worldx, y))
            b = kiosk.getpixel((x, y))
            art.putpixel((worldx, y), tuple(round(v * (1-alpha) + w * alpha)
                                              for v, w in zip(a, b)))

    # WebP is limited to 16383px per side; only the individual 960px tiles
    # use WebP. Keep the wide archival master as lossless PNG.
    master = args.out / 'quiosco_37440x390_CANDIDATE_NOT_FINAL.png'
    art.save(master, format='PNG', compress_level=6)
    pieces = args.out / 'tiles_NOT_ACTIVE'
    pieces.mkdir(exist_ok=True)
    for n in range(39):
        art.crop((n*960, 0, (n+1)*960, HEIGHT)).save(
            pieces / f'quiosco_{n:02d}.webp', format='WEBP', lossless=True, method=6)
    # Contact strips allow a reviewer to inspect each A/B/C connector at
    # native pixels without loading a 37k-wide image into an image viewer.
    seam_sheet = Image.new('RGB', (4*440, 5*390), '#273b51')
    for n in range(1, 18):
        anchor = n*(SOURCE_WIDTH-OVERLAP)
        seam_sheet.paste(art.crop((anchor-220, 0, anchor+220, HEIGHT)),
                         (((n-1)%4)*440, ((n-1)//4)*390))
    seam_sheet.save(args.out / 'contact_17_connectors_CANDIDATE.webp',
                    format='WEBP', quality=91, method=6)
    art.crop((KIOSK_X-700, 0, KIOSK_X+1700, HEIGHT)).save(
        args.out / 'kiosk_2400px_center_NOT_STAGEPAINTER.webp',
        format='WEBP', quality=94, method=6)
    record = {
        'status': 'CANDIDATE_REQUIRES_REAL_STAGEPAINTER_AND_ARTISTIC_JOIN_REVIEW',
        'world_width': WORLD, 'height': HEIGHT, 'tile_count': 39,
        'sources_count': len(names), 'original_sources': details,
        'kiosk_world_x': KIOSK_X, 'kiosk_width': 1170, 'kiosk_count': 1,
        'sha256_master': hashlib.sha256(master.read_bytes()).hexdigest(),
        'reason_not_activated': 'Blended seams A/B/C are unvalidated architecture',
    }
    (args.out / 'audit_candidate.json').write_text(
        json.dumps(record, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(json.dumps({'master': str(master), 'world': cursor, 'tiles': 39,
                      'sources': 18, 'landmark': 1, 'status': record['status']}))


if __name__ == '__main__':
    main()
