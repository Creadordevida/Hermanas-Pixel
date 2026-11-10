#!/usr/bin/env python3
"""Make Flutter-generated Android activity a real landscape full-screen game.

Default AndroidManifest from flutter create may letterbox on wide Xiaomi
phones if native aspect/orientation parameters are not explicit. Never
rewrite the app's package name, icons, launch modes, or other metadata.
"""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
MANIFEST=ROOT/'android/app/src/main/AndroidManifest.xml'
ANDROID='{http://schemas.android.com/apk/res/android}'
ET.register_namespace('android','http://schemas.android.com/apk/res/android')

def patch(path=MANIFEST):
    if not path.is_file():
        raise FileNotFoundError('Run flutter create --platforms=android first')
    tree=ET.parse(path)
    manifest=tree.getroot()
    application=manifest.find('application')
    if application is None:raise ValueError('No Android application')
    activity=application.find('activity')
    if activity is None:raise ValueError('No Android activity')
    activity.set(ANDROID+'screenOrientation','sensorLandscape')
    activity.set(ANDROID+'resizeableActivity','true')
    application.set(ANDROID+'maxAspectRatio','2.8')
    # Explicitly allow all broad phone ratios under Android 14 and earlier.
    if not any(x.get(ANDROID+'name')=='android.max_aspect'
               for x in application.findall('meta-data')):
        entry=ET.Element('meta-data')
        entry.set(ANDROID+'name','android.max_aspect')
        entry.set(ANDROID+'value','2.8')
        application.append(entry)
    tree.write(path,encoding='utf-8',xml_declaration=True)
    check=ET.parse(path).getroot().find('application')
    a=check.find('activity')
    assert a.get(ANDROID+'screenOrientation')=='sensorLandscape'
    assert a.get(ANDROID+'resizeableActivity')=='true'
    assert check.get(ANDROID+'maxAspectRatio')=='2.8'
    print('Native Android landscape + max-aspect 2.8 verified:',path)
if __name__=='__main__':
    patch()
