import 'dart:math' as math;

/// QA-only river stone. Fixed-step collision is checked DURING the trajectory,
/// so large frames cannot skip over a character between frame endpoints.
class ArgaStoneProjectile {
  ArgaStoneProjectile({
    required double originX,
    required double originY,
    required double targetX,
  }) : x=originX, y=originY,
       vx=(targetX-originX).clamp(-240.0,240.0).toDouble(),
       vy=-170;

  static const double gravity=520;
  static const double radius=7;
  static const double lifetime=1.8;
  double x,y,vx,vy;
  double age=0;
  bool active=true;
  bool delivered=false;

  /// Hero rectangle uses center X and top/bottom world-Y (feet at bottom).
  /// Returns true at most once; substeps cannot report duplicate damage.
  bool advance(double dt, {
    required double waterY,
    required double heroCenterX,
    required double heroHalfWidth,
    required double heroTop,
    required double heroBottom,
  }) {
    if(!active || dt<=0) return false;
    var remaining=math.min(dt,lifetime-age);
    while(remaining>1e-9 && active) {
      final step=math.min(remaining,1/120);
      x+=vx*step;
      y+=vy*step + .5*gravity*step*step;
      vy+=gravity*step;
      age+=step;
      remaining-=step;
      if(y>=waterY || age>=lifetime-1e-9) {
        active=false;
        break;
      }
      if(heroHalfWidth>=0 && heroBottom>=heroTop) {
        final nearX=x.clamp(heroCenterX-heroHalfWidth,
                            heroCenterX+heroHalfWidth);
        final nearY=y.clamp(heroTop,heroBottom);
        final dx=x-nearX,dy=y-nearY;
        if(dx*dx+dy*dy<=radius*radius) {
          delivered=true;
          active=false;
          return true;
        }
      }
    }
    return false;
  }

  void cancel()=>active=false;
}
