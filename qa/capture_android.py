#!/usr/bin/env python3
"""Capture real ADB screenshots for an EXACT APK, rejecting mismatched package.

Example (after installing the exact APK):
    python qa/capture_android.py app-release.apk title
    python qa/capture_android.py app-release.apk enemy_referee_attack
"""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,subprocess,sys,json
from check_evidence import REQUIRED_CAPTURES,ROOT
PACKAGE='com.example.hermanas_aventura'
def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def adb(*args):return subprocess.check_output(['adb',*args],timeout=22)
def capture(apk_arg,tag):
    if tag not in REQUIRED_CAPTURES:raise ValueError('Captura no prevista: '+tag)
    apk=Path(apk_arg).resolve()
    if not apk.exists():raise FileNotFoundError(apk)
    # Assert the game is the foreground app; an unrelated screenshot is forbidden.
    state=adb('shell','dumpsys','activity','activities').decode(errors='replace')
    lines=[x for x in state.splitlines() if any(y in x for y in ('mResumedActivity','topResumedActivity','mFocusedApp'))]
    if not any(PACKAGE in line for line in lines):
        raise RuntimeError('El juego no consta como aplicación activa por ADB: '+str(lines[-4:]))
    # Validate APK installed on device is BYTE IDENTICAL to APK to be reviewed.
    info=adb('shell','pm','path',PACKAGE).decode(errors='replace')
    remote=next((s[8:].strip() for s in info.splitlines() if s.startswith('package:') and s.endswith('/base.apk')),None)
    if remote is None:raise RuntimeError('No se encuentra base.apk del juego en Android')
    installed=adb('exec-out','cat',remote)
    apk_sha=digest(apk)
    if hashlib.sha256(installed).hexdigest()!=apk_sha:
        raise RuntimeError('El APK instalado NO coincide con el archivo indicado: NO se permite esta evidencia')
    png=adb('exec-out','screencap','-p')
    if not png.startswith(b'\x89PNG\r\n\x1a\n'):
        raise RuntimeError('Captura ADB no válida')
    d=ROOT/'evidence';d.mkdir(exist_ok=True)
    manifest=d/'manifest.json'
    data=json.loads(manifest.read_text()) if manifest.exists() else {}
    if data and data.get('apk_sha256')!=apk_sha:raise RuntimeError('No mezclar APK diferentes en un manifiesto')
    dst=d/f'{tag}.png';dst.write_bytes(png)
    data.update({'apk_file':str(apk.relative_to(ROOT)) if apk.is_relative_to(ROOT) else str(apk),
                 'apk_sha256':apk_sha,'capture_method':'adb exec-out screencap -p',
                 'app_package':PACKAGE})
    data.setdefault('screenshots',{})[tag]={
        'file':str(dst.relative_to(ROOT)),
        'sha256':hashlib.sha256(png).hexdigest(),
        'apk_sha256':apk_sha,'foreground_package':PACKAGE,
        'captured_utc':datetime.now(timezone.utc).isoformat()}
    manifest.write_text(json.dumps(data,indent=2,ensure_ascii=False))
    print('CAPTURA REAL DEL APK VERIFICADO:',dst)
if __name__=='__main__':
    if len(sys.argv)!=3:raise SystemExit('Uso: python qa/capture_android.py APP.apk ETIQUETA')
    capture(sys.argv[1],sys.argv[2])
