#!/usr/bin/env bash
# Río Arga: QA local gratis sin GitHub Actions ni APK.
set -euo pipefail
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no está instalado o no aparece en PATH." >&2
  exit 2
fi
flutter pub get
flutter analyze --no-pub lib
flutter test --no-pub --reporter expanded test/arga_platform_rules_test.dart test/arga_crossing_test.dart
flutter test --no-pub --reporter expanded test/arga_rc7_real_render_test.dart
python3 - <<'PY'
from pathlib import Path
from struct import unpack
files=sorted(Path('qa/arga_rc7_flutter').glob('qa_*.png'))
assert len(files)==8, f'Se esperaban ocho PNG y hay {len(files)}'
for path in files:
    data=path.read_bytes()
    assert len(data)>10000 and data[:8]==b'\x89PNG\r\n\x1a\n',path
    assert unpack('>II',data[16:24])==(1000,450),path
print('QA Arga: ocho capturas StagePainter 20:9 verificadas. No se generó APK.')
PY
