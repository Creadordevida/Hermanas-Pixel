import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_platform_rules.dart';

void main() {
  const course = ArgaCourse();

  test('Every authored gap is a real gap and reachable by current jump physics', () {
    expect(course.allGapsReachable, isTrue);
    expect(ArgaCourse.flatJumpRange, closeTo(148.9, .2));
    for (var i = 1; i < ArgaCourse.surfaces.length; i++) {
      final prev = ArgaCourse.surfaces[i-1];
      final next = ArgaCourse.surfaces[i];
      expect(next.x, greaterThan(prev.x + prev.width));
    }
  });

  test('Full authored river has safe jumps and recurring checkpoints', () {
    final all=ArgaCourse.allSurfaces;
    expect(all.length,greaterThan(100));
    expect(all.last.x+all.last.width,greaterThan(35900));
    expect(course.allGapsReachable,isTrue);
    for(var i=1;i<all.length;i++) {
      expect(all[i].x,greaterThan(all[i-1].x+all[i-1].width));
    }
    for(final point in [3000.0,9000.0,17000.0,28000.0,35000.0]) {
      final cp=course.checkpointBefore(point);
      expect(cp,lessThanOrEqualTo(point));
      expect(course.overPlatform(cp,14,0),isTrue);
    }
  });

  test('A standing hero can land on rocks but cannot land over open river', () {
    expect(course.landing(350, 370, 100, 14, 0), isNotNull);
    expect(course.landing(350, 370, 260, 14, 0), isNull);
    expect(course.overPlatform(260, 14, 0), isFalse);
  });

  test('Falling into a gap reaches the water death plane', () {
    expect(course.drowned(390), isFalse);
    expect(course.drowned(435), isFalse);
    expect(course.drowned(436), isTrue);
    expect(course.landing(425, 437, 260, 14, 0), isNull);
  });

  test('Moving log shifts and sinking rock sinks only after its warning', () {
    final moving=ArgaCourse.surfaces.firstWhere(
      (s)=>s.kind==ArgaSurfaceKind.movingLog);
    expect(moving.leftAt(0), isNot(moving.leftAt(2)));
    final sinking=ArgaCourse.surfaces.firstWhere(
      (s)=>s.kind==ArgaSurfaceKind.sinkingRock);
    expect(sinking.topAt(0, .5), sinking.top);
    expect(sinking.topAt(0, 1.5), greaterThan(sinking.top));
  });

  test('Checkpoint respawn is deterministic and never inside a river gap', () {
    expect(course.checkpointBefore(130), ArgaCourse.startX);
    final middle=course.checkpointBefore(1500);
    expect(middle, closeTo(1270, .001));
    expect(course.overPlatform(middle, 14, 0), isTrue);
    expect(course.checkpointBefore(2050), closeTo(1975, .001));
  });
}
