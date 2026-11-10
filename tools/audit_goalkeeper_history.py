"""Audit Git history for intact versions of six damaged goalkeeper sources.

Read-only: report Git blob hashes, first/last commits, and strict Pillow decoding.
No files are modified, and no automatic replacement is authorized.
"""
import io,json,subprocess
from PIL import Image
from pathlib import Path

NAMES=["shuffle_step_b","dive","dive_extension","hurt","defeat_side","defeated"]
PREFIX="qa/goalkeeper_rebuild_20261109/"
out=[]
for name in NAMES:
    path=PREFIX+f"pose_{name}_rgba.png"
    commits=subprocess.run(["git","log","--all","--format=%H","--",path],capture_output=True,text=True,check=True).stdout.splitlines()
    versions=[]
    seen=set()
    for commit in commits:
        blob=subprocess.run(["git","rev-parse",f"{commit}:{path}"],capture_output=True,text=True)
        if blob.returncode or blob.stdout.strip() in seen: continue
        sha=blob.stdout.strip();seen.add(sha)
        data=subprocess.run(["git","show",f"{commit}:{path}"],capture_output=True,check=True).stdout
        try:
            with Image.open(io.BytesIO(data)) as im:
                im.load()
                alpha=im.convert("RGBA").getchannel("A")
                bbox=alpha.point(lambda v:255 if v>=128 else 0).getbbox()
                status="valid"
                size=im.size
        except Exception as exc:
            status="invalid: "+str(exc)
            size=None;bbox=None
        versions.append(dict(commit=commit,blob=sha,bytes=len(data),status=status,size=size,bbox=bbox))
    out.append(dict(file=path,versions=versions))
    print(json.dumps(out[-1]))
report=Path("qa/goalkeeper_rebuild_20261109/history_audit.json")
report.write_text(json.dumps(out,indent=2)+"\n")
print("HISTORY_AUDIT_DONE")
