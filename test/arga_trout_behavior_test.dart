import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_trout_behavior.dart';

void main() {
  test('Trout warns before jumping out of the river',() {
    final trout=ArgaTroutMotion(600);
    trout.update(.1,650,playerVisible:true);
    expect(trout.pose,ArgaTroutPose.accelerate);
    trout.update(.56,650,playerVisible:true);
    expect(trout.pose,ArgaTroutPose.leap);
    trout.update(.12,650,playerVisible:true);
    expect(trout.y,lessThan(trout.waterY));
    expect(trout.airborne,isTrue);
  });

  test('Trout returns to water and requires cooldown',() {
    final trout=ArgaTroutMotion(600);
    trout.update(.1,650,playerVisible:true);
    expect(trout.pose,ArgaTroutPose.accelerate);
    trout.update(.23,650,playerVisible:true);
    trout.update(.56,650,playerVisible:true);
    trout.update(2,650,playerVisible:true);
    expect(trout.pose,ArgaTroutPose.swim);
    expect(trout.y,trout.waterY);
    expect(trout.cooldown,greaterThan(0));
  });

  test('A leap can hit only once and swimming cannot damage player',() {
    final trout=ArgaTroutMotion(600);
    expect(trout.touchesHero(centerX:600,halfWidth:20,top:300,bottom:430),isFalse);
    trout.update(.1,625,playerVisible:true);
    trout.update(.23,625,playerVisible:true);
    trout.update(.56,625,playerVisible:true);
    trout.update(.1,625,playerVisible:true);
    expect(trout.touchesHero(centerX:trout.x,halfWidth:20,top:200,bottom:430),isTrue);
    expect(trout.touchesHero(centerX:trout.x,halfWidth:20,top:200,bottom:430),isFalse);
  });

  test('Player hit interrupts leap and defeat is terminal',() {
    final trout=ArgaTroutMotion(600);
    trout.update(.1,650,playerVisible:true);
    expect(trout.pose,ArgaTroutPose.accelerate);
    trout.update(.23,650,playerVisible:true);
    trout.update(.56,650,playerVisible:true);
    trout.hit();
    expect(trout.pose,ArgaTroutPose.hurt);
    trout.defeat();
    trout.update(5,650,playerVisible:true);
    expect(trout.pose,ArgaTroutPose.defeated);
  });
}
