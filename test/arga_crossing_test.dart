import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_crossing.dart';

void main() {
  final section = ArgaCrossing.firstSection();

  test('the river begins with a safe bank and seven distinct crossings', () {
    expect(section.first.surface, ArgaSurface.bank);
    expect(section.first.left, 0);
    expect(section.first.right, ArgaCrossing.startBankEnd);
    expect(section.length, 8);
    for (var i = 1; i < section.length; i++) {
      expect(section[i].left, greaterThan(section[i - 1].right));
      expect(section[i].left - section[i - 1].right, lessThanOrEqualTo(100));
    }
  });

  test('a gap is not solid footing', () {
    expect(ArgaCrossing.supported(690, section), isFalse);
    expect(ArgaCrossing.supported(780, section), isTrue);
    expect(ArgaCrossing.supported(1180, section), isFalse);
  });

  test('the water is lethal only after falling below the supports', () {
    expect(ArgaCrossing.fellInWater(
      footX: 690, footY: 420, verticalVelocity: 380, footings: section), isTrue);
    expect(ArgaCrossing.fellInWater(
      footX: 780, footY: 420, verticalVelocity: 380, footings: section), isFalse);
    expect(ArgaCrossing.fellInWater(
      footX: 690, footY: 370, verticalVelocity: 380, footings: section), isFalse);
    expect(ArgaCrossing.fellInWater(
      footX: 690, footY: 420, verticalVelocity: -200, footings: section), isFalse);
  });
}
