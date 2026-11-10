import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/rival_player_atlas.dart';

void main() {
  test('all 24 authored silhouettes stay within their atlas cells', () {
    expect(rivalPlayerSilhouettes.length, 24);
    for (var i=0; i<24; i++) {
      final bounds=rivalPlayerSilhouettes[i];
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.top, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(rivalPlayerAtlasCell));
      expect(bounds.bottom, lessThanOrEqualTo(rivalPlayerAtlasCell));
      final source=rivalPlayerAtlasSource(i);
      expect(source.left, greaterThanOrEqualTo((i%4)*256));
      expect(source.right, lessThanOrEqualTo((i%4+1)*256));
      expect(source.bottom, lessThanOrEqualTo((i~/4+1)*256));
    }
  });

  test('idle, run, alert, shoulder lunge, hit and defeat use separate rows', () {
    const time=.28;
    int frame({bool moving=false,bool attacking=false,bool stunned=false,
      bool defeated=false,double cooldown=1,double distance=180}) =>
      rivalPlayerAtlasFrame(elapsed:time,moving:moving,attacking:attacking,
        stunned:stunned,defeated:defeated,attackCooldown:cooldown,
        heroDistance:distance);
    expect(frame(), inInclusiveRange(0,3));
    expect(frame(moving:true), inInclusiveRange(4,7));
    expect(frame(cooldown:0,distance:30), inInclusiveRange(8,11));
    expect(frame(attacking:true), inInclusiveRange(12,15));
    expect(frame(stunned:true), inInclusiveRange(16,19));
    expect(frame(defeated:true), 23);
  });

  test('attack, recoil and falling show each of their four authored frames', () {
    int frame({double death=0,double stun=0,double warning=0,
      bool defeated=false,bool stunned=false,bool attacking=false}) =>
      rivalPlayerAtlasFrame(elapsed:0,moving:false,
        attacking:attacking,stunned:stunned,defeated:defeated,
        attackCooldown:0,heroDistance:30,
        deathElapsed:death,stunRemaining:stun,
        warningRemaining:warning);
    expect([for (var i=0;i<4;i++) frame(defeated:true,death:i*.16)],
      [20,21,22,23]);
    expect([for (var i=0;i<4;i++) frame(stunned:true,stun:.66-i*.165)],
      [16,17,18,19]);
    expect([for (var i=0;i<4;i++) frame(attacking:true,warning:.36-i*.09)],
      [12,13,14,15]);
  });
}
