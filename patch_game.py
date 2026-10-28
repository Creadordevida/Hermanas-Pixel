from pathlib import Path
p=Path('/mnt/data/working_football/lib/main.dart')
s=p.read_text()
s=s.replace("'rat', 'rival', 'referee', 'novice'", "'rat', 'rival', 'goalkeeper', 'referee', 'novice'")
s=s.replace("bool get ranged => ['referee'", "bool get ranged => ['referee'") # goalkeeper is melee
s=s.replace("int get hp => kind == 'dog_doberman' ? 2 : ranged ? 3 : 1;", "int get hp => (kind == 'dog_doberman' || kind == 'goalkeeper') ? 2 : ranged ? 3 : 1;")
s=s.replace("'rival' => 90, 'novice'", "'rival' => 90, 'goalkeeper' => 80, 'novice'")
s=s.replace("double get detection => kind == 'dog_dalmatian'", "double get detection => kind == 'goalkeeper' ? 230 : kind == 'dog_dalmatian'")
s=s.replace("4 => ['rival','referee'],", "4 => ['rival','goalkeeper','referee'],")
s=s.replace("for (final v in ['rival','referee','novice'", "for (final v in ['rival','goalkeeper','referee','novice'")
s=s.replace("if (prog<.3 && ['referee'", "if (prog<.3 && ['goalkeeper','referee'")
s=s.replace("      if(foe.ranged) {", """      if(foe.kind=='goalkeeper') {
        // Intermediate threat: restricted patrol, readable wind-up then ONE dive.
        // The keeper never teleports, throws projectiles or attacks immediately.
        if(foe.launched) {
          if(foe.t >= .34 && foe.t < .52 && !foe.biteApplied) {
            foe.biteApplied=true;
            if(absDist<52 && hero.y>groundY-60) _receiveDamage(foe.facing);
          }
          if(foe.t>=.75) {
            foe.launched=false;foe.biteApplied=false;
            foe.attackCooldown=2.7;foe.t=0;
          }
        } else if(absDist < 95 && foe.attackCooldown<=0) {
          foe.launched=true;foe.biteApplied=false;foe.t=0;
          foe.facing=distance>=0?1:-1;
        } else if(absDist<foe.detection) {
          foe.facing=distance>=0?1:-1;
          if(absDist>85)foe.x+=foe.facing*foe.speed*dt;
        } else {
          foe.x+=foe.facing*foe.speed*.18*dt;
          if((foe.x-foe.home).abs()>95)foe.facing=-foe.facing;
        }
      } else if(foe.ranged) {""")
s=s.replace("'rival','referee','novice','breakdancer','pigeon'", "'rival','goalkeeper','referee','novice','breakdancer','pigeon'")
s=s.replace("'rival' => 124.0, 'novice'", "'rival' => 124.0, 'goalkeeper' => 121.0, 'novice'")
s=s.replace("frame=foe.kind=='referee' ? 2", "frame=foe.kind=='goalkeeper' ? 2 : foe.kind=='referee' ? 2")
s=s.replace("frame=foe.ranged ? 1 : 3;", "frame=foe.ranged ? 1 : 3;")
s=s.replace("final lean=foe.launched ? -0.085 :", "final lean=foe.launched && foe.kind!='goalkeeper' ? -0.085 :")
p.write_text(s)
# custom goalkeeper visible bounds from actual transparent sprites
from PIL import Image
boundfile=Path('/mnt/data/working_football/lib/sprite_bounds.g.dart')
b=boundfile.read_text()
lines=[]
for i in range(5):
 im=Image.open('/mnt/data/working_football/assets/images/enemies/goalkeeper_%d.png'%i).convert('RGBA');bb=im.getchannel('A').getbbox();assert bb
 lines.append("  'goalkeeper_%d': Rect.fromLTWH(%.1f, %.1f, %.1f, %.1f),"%(i,bb[0],bb[1],bb[2]-bb[0],bb[3]-bb[1]))
b=b.replace("  'rival_0':",'\n'.join(lines)+"\n  'rival_0':")
boundfile.write_text(b)
# manifest must load goalkeeper assets already in general enemy loader, since list replaced
print('goalkeeper integrated',len(s),lines)
