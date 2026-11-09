#!/usr/bin/env python3
"""Preview architectural seam screens in an isolated Quiosco panorama.

This never edits assets/images or lib/main.dart. Generated separator art is
experimental and cannot be promoted without inspecting StagePainter frames.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SEPARATORS = ROOT / 'qa/quiosco_inbox/separators'
JOIN_STEP = 2172 - 96
KIOSK_START, KIOSK_END = 17920, 19090
# Sparse placement protects the plaza from a repetitive prop every 2076px.
# Omitted joins retain the existing source artwork without fake landmarks.
SELECTED = {1: 'lamppost', 3: 'tree',
            6: 'tree', 7: 'lamppost', 10: 'lamppost',
            12: 'tree', 15: 'tree', 16: 'lamppost'}


def sprite(name: str, height: int) -> Image.Image:
    raw = Image.open(SEPARATORS / f'{name}_qa.png').convert('RGBA')
    alpha = raw.getchannel('A')
    # ImageGen leaves a low-opacity aura, particularly around lamplight.
    # Use an alpha gate so soft rectangular haze never reaches gameplay art.
    alpha = alpha.point(lambda v: 255 if v >= 205 else 0)
    box = alpha.getbbox()
    if box is None:
        raise ValueError(f'{name}: no opaque art')
    raw.putalpha(alpha)
    raw = raw.crop(box)
    width = round(raw.width * height / raw.height)
    return raw.resize((width, height), Image.Resampling.LANCZOS)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--master', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    background = Image.open(args.master).convert('RGBA')
    if background.size != (37440, 390):
        raise ValueError(f'Unexpected candidate size: {background.size}')

    placements = []
    for index in range(1, 18):
        center = index * JOIN_STEP
        if index not in SELECTED:
            placements.append({'join': index, 'status': 'preserved_original'})
            continue
        # Never cover the historic music kiosk or any part of its approach.
        if center - 170 < KIOSK_END and center + 170 > KIOSK_START:
            placements.append({'join': index, 'status': 'skipped_landmark'})
            continue
        kind = SELECTED[index]
        height = {'tree': 275, 'lamppost': 285, 'pilaster': 270}[kind]
        height += ((index % 4) - 2) * 7
        overlay = sprite(kind, height)
        x = center - overlay.width // 2
        y = 382 - overlay.height
        background.alpha_composite(overlay, (x, y))
        placements.append({'join': index, 'status': 'qa_overlay',
                           'kind': kind, 'x': x, 'y': y,
                           'width': overlay.width, 'height': overlay.height})

    result = background.convert('RGB')
    result.save(args.out / 'quiosco_37440_SEPARATORS_QA_NOT_FINAL.png',
                optimize=True)
    contact = Image.new('RGB', (4*440, 5*390), '#273b51')
    for index in range(1, 18):
        center = index * JOIN_STEP
        fragment = result.crop((center-220, 0, center+220, 390))
        contact.paste(fragment, (((index-1) % 4)*440,
                                 ((index-1) // 4)*390))
    contact.save(args.out / 'contact_17_separators_QA_NOT_FLUTTER.webp',
                 format='WEBP', quality=94)
    (args.out / 'separators_qa.json').write_text(json.dumps({
        'status': 'VISUAL_CANDIDATE_ONLY_NOT_STAGEPAINTER_NOT_APPROVED',
        'original_panorama_untouched': str(args.master),
        'placements': placements,
    }, indent=2) + '\n', encoding='utf-8')
    print('QUIOSCO_SEPARATOR_CANDIDATE_READY', len(placements))


if __name__ == '__main__':
    main()
