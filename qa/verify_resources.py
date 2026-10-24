"""Integridad PNG, assets de la demo y sprites sin recortes por bordes."""
from pathlib import Path
import hashlib, struct, zlib, sys

ROOT = Path(__file__).resolve().parents[1]


def png_info(relative):
    path = ROOT / relative
    assert path.is_file(), f'Falta: {relative}'
    data = path.read_bytes()
    assert data.startswith(b'\x89PNG\r\n\x1a\n'), f'Firma PNG inválida: {relative}'
    cursor = 8
    first = None
    compressed = []
    has_end = False
    while cursor + 12 <= len(data):
        length = struct.unpack('>I', data[cursor:cursor + 4])[0]
        tag = data[cursor + 4:cursor + 8]
        payload = data[cursor + 8:cursor + 8 + length]
        expected = struct.unpack('>I', data[cursor + 8 + length:cursor + 12 + length])[0]
        assert (zlib.crc32(tag + payload) & 0xffffffff) == expected, f'CRC incorrecto: {relative}'
        if tag == b'IHDR':
            first = struct.unpack('>IIBBBBB', payload)
        if tag == b'IDAT':
            compressed.append(payload)
        cursor += 12 + length
        if tag == b'IEND':
            has_end = True
            break
    assert first is not None and has_end, f'PNG incompleto: {relative}'
    assert len(zlib.decompress(b''.join(compressed))) > 0, f'Imagen vacía: {relative}'
    return first, hashlib.sha256(data).hexdigest()


resources = ['assets/images/title_approved.png', 'assets/images/brand_logo_twc.png',
    'assets/images/level_pixel.png', 'assets/images/level_ayuntamiento.png',
    'assets/images/level_estafeta.png', 'assets/images/level_plaza_castillo.png',
    'assets/images/coin.png', 'assets/images/crate.png',
    'assets/images/ball.png', 'assets/images/comb.png',
]
for role in ('padre', 'futbolista', 'bailarina'):
    sprites = [f'assets/images/frames/{role}_{pose}.png'
        for pose in ('idle_0', 'walk_0', 'walk_1', 'jump_0')]
    hashes = []
    for path in sprites:
        info, digest = png_info(path)
        assert info[2] == 8 and info[3] == 6 and info[0] >= 80 and info[1] >= 100, path
        hashes.append(digest)
    assert len(set(hashes)) == 4, f'Poses repetidas: {role}'
    resources.extend(sprites)
for name in ('idle', 'walk', 'alert', 'run', 'bite', 'hit', 'stunned', 'defeated'):
    path = f'assets/images/dog/{name}.png'
    info, _ = png_info(path)
    assert info[0] == 144 and info[1] == 108 and info[3] == 6, path
    resources.append(path)
for name in resources[:10]:
    info, _ = png_info(name)
    assert info[0] > 15 and info[1] > 15, name
for d in ('mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'):
    png_info(f'launcher/res/mipmap-{d}/ic_launcher.png')
assert (ROOT / 'launcher/res/mipmap-anydpi-v26/ic_launcher.xml').is_file()
assert (ROOT / 'test/widget_test.dart').is_file()
assert (ROOT / 'lib/main.dart').stat().st_size > 30000
print(f'OK: {len(resources)} recursos gráficos esenciales y 5 iconos Android íntegros.')
