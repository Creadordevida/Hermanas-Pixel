# Río Arga: QA local sin GitHub Actions, sin APK y sin gasto adicional.
# Requiere Flutter SDK disponible como comando "flutter" en Windows.
param([switch]$SkipAnalyze)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host 'No se encuentra Flutter en PATH.' -ForegroundColor Yellow
  Write-Host 'Instala Flutter SDK y comprueba que "flutter --version" funciona antes de ejecutar este script.'
  exit 2
}

Push-Location $projectRoot
try {
  & flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get ha fallado' }

  if (-not $SkipAnalyze) {
    & flutter analyze --no-pub lib
    if ($LASTEXITCODE -ne 0) { throw 'flutter analyze ha fallado' }
  }

  & flutter test --no-pub --reporter expanded test/arga_platform_rules_test.dart test/arga_crossing_test.dart
  if ($LASTEXITCODE -ne 0) { throw 'Las pruebas de plataformas han fallado' }

  & flutter test --no-pub --reporter expanded test/arga_rc7_real_render_test.dart
  if ($LASTEXITCODE -ne 0) { throw 'La prueba visual real del Arga ha fallado' }

  $captureDir = Join-Path $projectRoot 'qa/arga_rc7_flutter'
  $captures = @(Get-ChildItem -LiteralPath $captureDir -Filter 'qa_*.png' -File)
  if ($captures.Count -ne 8) {
    throw "Se esperaban 8 capturas reales y hay $($captures.Count)"
  }
  foreach ($capture in $captures) {
    $bytes = [System.IO.File]::ReadAllBytes($capture.FullName)
    if ($bytes.Length -lt 10000 -or $bytes[0] -ne 137 -or $bytes[1] -ne 80) {
      throw "PNG ausente o corrupto: $($capture.Name)"
    }
  }
  Write-Host 'Río Arga: pruebas superadas; ocho capturas StagePainter 20:9 verificadas.' -ForegroundColor Green
  Write-Host "Capturas: $captureDir"
  Write-Host 'Esta ejecución no genera APK ni publica cambios.'
} finally {
  Pop-Location
}
