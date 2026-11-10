"""Install illustrated candidates without procedural fallback. Art signoff remains separate."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[1]
HASHES={'supporter':'ed3cfffd5293982ccfdc679cd2f6c0849303fe85fc2f37029e77bf6ee58b7e1c','tourist':'c295493f1c04e71db5a9a6dee23fbb420a41c3b3a8d26d05248280c5f35aa143','navarre_king':'3d02bf4d51e466a270c08e45b1d7ce4598f080d94ffae2d30d72368186de692c','estafeta_bull':'bfae72e10c896bdb24b0c02bd652faf2b5b57eb2ca7b9429b7a486ca9666416c'}
def install(kind):
 src=ROOT/'qa/enemy_art_20261031'/f'{kind}_atlas_candidate.png'
 data=src.read_bytes()
 assert hashlib.sha256(data).hexdigest()==HASHES[kind], 'Illustrated source mismatch: '+kind
 dst=ROOT/'assets/images/enemies_new'/f'{kind}_atlas.png'
 dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(data)
 return dst
