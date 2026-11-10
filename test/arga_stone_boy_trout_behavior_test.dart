import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_stone_boy_trout_behavior.dart';

void main() {
  test('gamberro telegraphs and throws exactly one river pebble', () {
    final boy = ArgaStoneBoyMotion(400);
    boy.update(.016, 550, playerVisible:true);
    expect(boy.pose,ArgaStoneBoyPose.warning);
    var stones=0;
    for(var i=0;i<110;i++) {
      if(boy.update(.016,550,playerVisible:true)) stones++;
    }
    expect(stones,1);
  });

  test('stone boy cannot cross edge and is silenced by defeat', () {
    final boy = ArgaStoneBoyMotion(400,minX:380,maxX:420);
    for(var i=0;i<200;i++) {
      boy.update(.016,720,playerVisible:true);
    }
    expect(boy.x,inInclusiveRange(380,420));
    boy.defeat();
    final before=boy.x;
    for(var i=0;i<120;i++) {
      expect(boy.update(.016,450,playerVisible:true),isFalse);
    }
    expect(boy.x,before);
  });

  test('trout visibly warns, jumps, then returns to river', () {
    final trout = ArgaTroutMotion(500,430);
    trout.update(.016,500,400);
    expect(trout.pose,ArgaTroutPose.alert);
    var impacts=0, sawLeap=false;
    for(var i=0;i<200;i++) {
      if(trout.update(.016,500,400)) impacts++;
      if(trout.pose==ArgaTroutPose.leap) sawLeap=true;
    }
    expect(sawLeap,isTrue);
    expect(impacts,lessThanOrEqualTo(1));
    expect(trout.pose,isNot(ArgaTroutPose.defeated));
  });

  test('defeated trout never reattacks or leaves its defeat state', () {
    final trout = ArgaTroutMotion(500,430);
    trout.defeat();
    for(var i=0;i<200;i++) {
      expect(trout.update(.016,500,400),isFalse);
      expect(trout.pose,ArgaTroutPose.defeated);
    }
  });
}
