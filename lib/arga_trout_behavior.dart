import 'dart:math' as math;

/// QA-only trout. Its baseline is WATER; unlike land enemies it never stands
/// on a rock. World Y increases downwards.
enum ArgaTroutPose { swim, accelerate, warning, leap, hurt, defeated }

class ArgaTroutMotion {
  ArgaTroutMotion(this.homeX,{this.waterY=421}) : x=homeX,y=waterY;
  final double homeX,waterY;
  double x,y,vx=0,vy=0,elapsed=0,cooldown=0;
  int facing=-1;
  ArgaTroutPose pose=ArgaTroutPose.swim;
  bool touchDelivered=false;
  static const double detection=190;
  static const double accelerationDuration=.22;
  static const double warningDuration=.55;
  static const double jumpSpeed=330;
  static const double gravity=900;

  bool get airborne=>pose==ArgaTroutPose.leap && y<waterY;
  bool get defeated=>pose==ArgaTroutPose.defeated;

  void _set(ArgaTroutPose next) {
    if(pose==next)return;
    pose=next;elapsed=0;
  }

  void hit() {
    if(defeated)return;
    _set(ArgaTroutPose.hurt);
    vx=0;vy=0;touchDelivered=true;
    cooldown=math.max(cooldown,1.2);
  }
  void defeat() {
    _set(ArgaTroutPose.defeated);vx=0;vy=0;touchDelivered=true;
  }

  void update(double dt,double heroX,{required bool playerVisible}) {
    if(dt<=0 || defeated)return;
    elapsed+=dt;
    cooldown=math.max(0,cooldown-dt);
    if(pose==ArgaTroutPose.hurt) {
      if(elapsed>.3) {_set(ArgaTroutPose.swim);y=waterY;}
      return;
    }
    if(pose==ArgaTroutPose.leap) {
      // Fixed microsteps keep splash return deterministic on slow frames.
      var left=dt;
      while(left>1e-9 && pose==ArgaTroutPose.leap) {
        final step=math.min(left,1/120);
        x+=vx*step;
        y+=vy*step+.5*gravity*step*step;
        vy+=gravity*step;
        left-=step;
        if(y>=waterY && vy>0) {
          y=waterY;vx=0;vy=0;
          cooldown=2.4;_set(ArgaTroutPose.swim);
        }
      }
      return;
    }
    if(pose==ArgaTroutPose.accelerate) {
      if(!playerVisible) {_set(ArgaTroutPose.swim);return;}
      if(elapsed>=accelerationDuration) _set(ArgaTroutPose.warning);
      return;
    }
    if(pose==ArgaTroutPose.warning) {
      if(!playerVisible) {_set(ArgaTroutPose.swim);return;}
      if(elapsed>=warningDuration) {
        facing=heroX>=x?1:-1;
        vx=facing*118;vy=-jumpSpeed;
        touchDelivered=false;
        _set(ArgaTroutPose.leap);
      }
      return;
    }
    if(playerVisible && cooldown<=0 && (heroX-x).abs()<detection) {
      facing=heroX>=x?1:-1;
      _set(ArgaTroutPose.accelerate);
    } else {
      _set(ArgaTroutPose.swim);
    }
  }

  bool touchesHero({required double centerX,required double halfWidth,
                    required double top,required double bottom}) {
    if(!airborne || touchDelivered || halfWidth<0 || bottom<top)return false;
    final px=x.clamp(centerX-halfWidth,centerX+halfWidth);
    final py=y.clamp(top,bottom);
    final dx=x-px,dy=y-py;
    if(dx*dx+dy*dy>18*18)return false;
    touchDelivered=true;
    return true;
  }
}
