// QA-only: the next-release map exposes stage eight without hiding old chapters.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Arga appears as eighth map chapter and can be selected',
      (tester) async {
    expect(twcArgaNextVersionEnabled, isTrue);
    expect(twcChapterCount, 8);
    expect(chapterNames.length, 8);
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1000, 450));
    final key = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: HermanasGame(
        key: key, qaMap: true,
      )));
      await tester.pump();
      expect(find.text('8 · RÍO ARGA'), findsOneWidget);
      expect(find.textContaining('COMPLETADOS: 0/8'), findsOneWidget);
      await tester.tap(find.text('8 · RÍO ARGA'));
      await tester.pump();
      final dynamic game = key.currentState;
      expect(game.stage, 7);
      expect(game.screen, Screen.choose);
      expect(game.argaCrab, isNotNull);
      expect(game.argaFisher, isNotNull);
      expect(game.argaBoy, isNotNull);
      expect(game.argaTrout, isNotNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    }
  });
}
