#!/usr/bin/env python3
"""Very limited Dart delimiter sanity check; cannot replace Dart analyzer."""
from pathlib import Path
s=(Path(__file__).resolve().parents[1]/'lib/main.dart').read_text()
# Strips quoted strings/comments through a conservative state machine.
stack=[];line=1;quote=None;escaped=False;comment=False;block=False
pairs={')':'(',']':'[','}':'{'}
for i,ch in enumerate(s):
 if ch=='\n':line+=1;comment=False
 if comment:continue
 if quote:
  if escaped:escaped=False
  elif ch=='\\':escaped=True
  elif ch==quote:quote=None
  continue
 if block:
  if ch=='/' and i>0 and s[i-1]=='*':block=False
  continue
 nxt=s[i+1] if i+1<len(s) else ''
 if ch=='/' and nxt=='/':comment=True;continue
 if ch=='/' and nxt=='*':block=True;continue
 if ch in ('\'','"'):quote=ch;continue
 if ch in '([{':stack.append((ch,line))
 elif ch in ')]}':
  if not stack or stack[-1][0]!=pairs[ch]:raise SystemExit(f'Unbalanced {ch} near line {line}')
  stack.pop()
if stack:raise SystemExit('Unclosed braces: '+str(stack[-4:]))
print('Delimitadores equilibrados (NO certifica sintaxis Dart ni compilación)')
