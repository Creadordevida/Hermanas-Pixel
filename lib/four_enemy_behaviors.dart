import 'dart:math' as math;

const fourEnemyStages = <String, int>{
  'dance_cleaner': 5, 'guitar_musician': 5,
  'slipper_neighbor': 0, 'rival_coach': 4,
};
enum FourEnemyPose { idle, walk, warning, attack, hit, defeated }
enum FourEnemyImpact { none, melee, slipper }

List<double> fourEnemySpawns(String kind, int stage, double width) {
  if(fourEnemyStages[kind]!=stage || width<4000) return [];
  final fractions=switch(kind) {
    'dance_cleaner' => [.18,.54,.83],
    'guitar_musician' => [.33,.67,.91],
    'slipper_neighbor' => [.16,.48,.78],
    _ => [.24,.58,.86],
  };
  return fractions.map((f)=>width*f).toList();
}

/// Clock shared by animation and damage. Warning fixes facing; impact occurs
/// exactly once at the extension pose, never at the start of the warning.
class FourEnemyMotion {
  FourEnemyMotion(this.kind, this.home) : x=home;
  final String kind;
  final double home;
  double x;
  int facing=1;
  FourEnemyPose pose=FourEnemyPose.idle;
  double phase=0, cooldown=0;
  bool delivered=false;
  bool get ranged => kind=='slipper_neighbor';
  double get warningDuration => ranged?.75:kind=='guitar_musician'?.62:.52;
  double get reach => ranged?390:kind=='dance_cleaner'?83:kind=='guitar_musician'?78:65;
  double get recovery => ranged?3.6:2.4;
  double get jumpClearance => kind=='dance_cleaner'?44:60;
  int get frame => switch(pose) {
    FourEnemyPose.warning => (phase/warningDuration*4).floor().clamp(0,3),
    FourEnemyPose.attack => (phase/.44*4).floor().clamp(0,3),
    FourEnemyPose.hit => (phase/.36*4).floor().clamp(0,3),
    FourEnemyPose.defeated => (phase/.48*4).floor().clamp(0,3),
    FourEnemyPose.walk => (phase*7).floor()%4,
    FourEnemyPose.idle => (phase*3).floor()%4,
  };
  void setPose(FourEnemyPose value) {
    if(pose!=value) {pose=value;phase=0;}
  }
  void hit() {setPose(FourEnemyPose.hit);phase=0;delivered=true;cooldown=math.max(cooldown,1.0);}
  void defeat() {setPose(FourEnemyPose.defeated);phase=0;delivered=true;}

  FourEnemyImpact update(double dt,double heroX,double heroY,double ground) {
    if(dt<=0 || pose==FourEnemyPose.defeated) return FourEnemyImpact.none;
    phase+=dt;cooldown=math.max(0.0,cooldown-dt);
    final dx=heroX-x, near=dx.abs();
    if(pose==FourEnemyPose.hit) {
      if(phase>=.36)setPose(FourEnemyPose.idle);
      return FourEnemyImpact.none;
    }
    if(pose==FourEnemyPose.warning) {
      if(phase>=warningDuration) {setPose(FourEnemyPose.attack);delivered=false;}
      return FourEnemyImpact.none;
    }
    if(pose==FourEnemyPose.attack) {
      if(!delivered && phase>=.11) {
        delivered=true;
        if(ranged) return FourEnemyImpact.slipper;
        if(near<reach && dx*facing>=-8 && heroY>ground-jumpClearance) {
          return FourEnemyImpact.melee;
        }
      }
      if(phase>=.44) {cooldown=recovery;setPose(FourEnemyPose.idle);}
      return FourEnemyImpact.none;
    }
    if(near<reach && cooldown<=0) {
      facing=dx>=0?1:-1;setPose(FourEnemyPose.warning);
    } else if(!ranged && near<240 && near>reach*.8) {
      facing=dx>=0?1:-1;setPose(FourEnemyPose.walk);
      x+=facing*48*dt;
    } else {setPose(FourEnemyPose.idle);}
    x=x.clamp(home-160,home+160).toDouble();
    return FourEnemyImpact.none;
  }
}
