// QA-only: the next-release map exposes stage eight without hiding old chapters.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

Future<void> waitForMapBitmap(WidgetTester tester) async {
  const asset='assets/images/worldmap/pamplona_wide_20x9_approved.webp';
  for(var i=0;i<240;i++) {
    await tester.pump(const Duration(milliseconds: 50));
    final matches=find.byWidgetPredicate((w)=>
      w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName==asset);
    if(matches.evaluate().isNotEmpty) {
      final rendered=find.descendant(of:matches,matching:find.byType(RawImage));
      if(tester.widgetList<RawImage>(rendered).any((w)=>w.image!=null)) return;
    }
    await tester.runAsync(()=>
      Future<void>.delayed(const Duration(milliseconds: 20)));
  }
  throw StateError('Map artwork was never decoded');
}

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
    final imageKey = GlobalKey();
    try {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: HermanasGame(key: key, qaMap: true),
      )));
      await waitForMapBitmap(tester);
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('8 · RÍO ARGA'), findsOneWidget);
      expect(find.textContaining('COMPLETADOS: 0/8'), findsOneWidget);
      final entryRect = tester.getRect(find.text('8 · RÍO ARGA'));
      final counterRect = tester.getRect(find.textContaining('COMPLETADOS: 0/8'));
      expect(entryRect.overlaps(counterRect), isFalse,
          reason: 'Arga entry must not be hidden by map counter');
      expect(entryRect.left, greaterThanOrEqualTo(0));
      expect(entryRect.right, lessThanOrEqualTo(1000));
      final boundary = imageKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      expect(boundary.debugNeedsPaint, isFalse);
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 1);
        try {
          final png = await picture.toByteData(format: ui.ImageByteFormat.png);
          expect(png, isNotNull);
          final file = File('qa/arga_rc7_flutter/arga_next_version_map.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
          expect(await file.length(), greaterThan(10000));
        } finally { picture.dispose(); }
      });
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
