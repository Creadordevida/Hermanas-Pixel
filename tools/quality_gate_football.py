"""Visual quality gate: fail on unreviewed keeper art, even if code and assets are valid."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
result={
 'project':'Hermanas Pixel', 'phase':'RC3 laboratory, not a release',
 'technical_integrity':'pass', 'goalkeeper_mechanics':'prototype_only',
 'goalkeeper_art':'FAIL: blocking pose reads as running; hands not convincing for a goalkeeper',
 'football_scene':'FAIL: simulated field-ground join has a flat untextured stripe',
 'chapter1_transition':'FAIL: authentic geographical seam still requires approved connector art',
 'flutter_compilation':'NOT_RUN: Flutter SDK unavailable',
 'release_approved':False
}
q=ROOT/'qa'/'goalkeeper_scene_quality_gate.json';q.parent.mkdir(exist_ok=True);q.write_text(json.dumps(result,indent=2,ensure_ascii=False))
print(json.dumps(result,indent=2,ensure_ascii=False))
