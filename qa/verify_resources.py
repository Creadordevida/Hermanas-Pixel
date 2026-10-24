"""Verificación PNG con Python estándar: formatos, dimensiones, alfa y poses."""
from pathlib import Path
import struct, hashlib, zlib, json, sys

root=Path(__file__).resolve().parents[1]
roles=('padre','futbolista','bailarina')
poses=('idle_0','walk_0','walk_1','jump_0')

def png_info(path):
    data=path.read_bytes()
    assert data[:8]==b'\x89PNG\r\n\x1a\n',f'No es PNG: {path}'
    cursor=8
    hdr=None; compressed=b''
    while cursor<len(data):
        n=struct.unpack('>I',data[cursor:cursor+4])[0]
        tp=data[cursor+4:cursor+8]
        payload=data[cursor+8:cursor+8+n]
        crc=struct.unpack('>I',data[cursor+8+n:cursor+12+n])[0]
        assert (zlib.crc32(tp+payload)&0xffffffff)==crc,f'PNG CRC error: {path}'
        if tp==b'IHDR':hdr=struct.unpack('>IIBBBBB',payload)
        if tp==b'IDAT':compressed+=payload
        cursor+=12+n
        if tp==b'IEND':break
    assert hdr is not None
    zlib.decompress(compressed)
    return hdr,hashlib.sha256(data).hexdigest()

for role in roles:
    unique=[]
    for pose in poses:
        path=root/'assets/images/frames'/f'{role}_{pose}.png'
        assert path.is_file(), f'Falta sprite: {path}'
        (w,h,depth,color,comp,filter,interlace),hashval=png_info(path)
        assert depth==8 and color==6 and w>=80 and h>=100,f'PNG no RGBA o dimensiones: {path}'
        unique.append(hashval)
    assert len(set(unique))==len(poses),f'Poses duplicadas: {role}'

for name in ['level_pixel.png','crate.png','coin.png']:
    assert (root/'assets/images'/name).exists()
    info,_=png_info(root/'assets/images'/name)
    if name=='level_pixel.png':
        assert info[0]>=1200 and info[1]>=450,'Escenario demasiado pequeño'
report=json.loads((root/'qa/sprite_audit.json').read_text())
assert len(report)==12
for row in report:
    assert row['magenta_in_opaque_pixels']<=3, f'Contaminación de fondo: {row}'
print('PASS: 12 sprites RGBA completos, diferentes y con PNG válidos; escenario, monedas y cajas íntegros')
