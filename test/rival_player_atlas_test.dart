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
}
