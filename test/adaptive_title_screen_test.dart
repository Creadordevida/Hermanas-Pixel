import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/adaptive_title_screen.dart';

void main() {
  const sizes=<Size>[
    Size(800,450),      // 16:9
    Size(900,450),      // 18:9
    Size(975,450),      // 19.5:9
    Size(1000,450),     // 20:9
    Size(2340,1080),   // modern landscape Android, 19.5:9
    Size(2400,1080),   // modern landscape Android, 20:9
  ];

  test('The entire unchanged 800x450 title is available at all ratios', () {
    for (final sz in sizes) {
      final g=TitleGeometry(sz);
      expect(TitleGeometry.supportsAspect(sz),isTrue);
      expect(g.canShowCentralUncropped,isTrue);
      final central=Rect.fromLTWH(
        g.insetX,0,g.centralWidth,sz.height);
      expect(central.left,greaterThanOrEqualTo(0));
      expect(central.right,lessThanOrEqualTo(sz.width+.02));
      expect(central.width / central.height,closeTo(16/9,.00001));
      final newGame=g.newGame,continueGame=g.continueGame;
      expect(newGame.left,greaterThan(central.left));
      expect(newGame.right,lessThan(central.right));
      expect(continueGame.left,greaterThan(central.left));
      expect(continueGame.right,lessThan(central.right));
      expect(newGame.bottom,lessThan(continueGame.top));
      expect(g.logo.center.dx,closeTo(sz.width/2,.01));
    }
  });

  test('The panoramic source crops SIDE ART only, never the title itself', () {
    const panorama=Size(1000,450);
    for (final sz in sizes) {
      final source=TitleGeometry(sz).panoramaSource(panorama);
      expect(source.top,0);
      expect(source.bottom,450);
      expect(source.left,greaterThanOrEqualTo(0));
      expect(source.right,lessThanOrEqualTo(1000));
      // The approved original is embedded exactly at x=100..900 in source.
      expect(source.left,lessThanOrEqualTo(100));
      expect(source.right,greaterThanOrEqualTo(900));
    }
  });

  testWidgets('Both title touch surfaces stay at drawn button positions',
      (tester) async {
    var started=0,continued=0;
    for (final sz in sizes.take(4)) {
      await tester.binding.setSurfaceSize(sz);
      await tester.pumpWidget(MaterialApp(
        home:Scaffold(body:AdaptiveTitleScreen(
          onNewGame:()=>started++,onContinue:()=>continued++,
          hasSavedGame:true,
        )),
      ));
      await tester.pump();
      expect(find.byKey(const ValueKey('title-new-game')),findsOneWidget);
      expect(find.byKey(const ValueKey('title-continue')),findsOneWidget);
      // The test taps REAL hitboxes, not a fake title screenshot.
      final buttons=TitleGeometry(sz);
      final first=find.byKey(const ValueKey('title-new-game'));
      final second=find.byKey(const ValueKey('title-continue'));
      expect(tester.getRect(first).center.dx,
          closeTo(buttons.newGame.center.dx,.01));
      expect(tester.getRect(first).center.dy,
          closeTo(buttons.newGame.center.dy,.01));
      expect(tester.getRect(second).center.dx,
          closeTo(buttons.continueGame.center.dx,.01));
      await tester.tap(first);
      await tester.pump();
      await tester.tap(second);
      await tester.pump();
    }
    expect(started,4);
    expect(continued,4);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Continue cannot be tapped without a saved game',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000,450));
    var newCount=0,continueCount=0;
    await tester.pumpWidget(MaterialApp(
      home:Scaffold(body:AdaptiveTitleScreen(
        onNewGame:()=>newCount++,
        onContinue:()=>continueCount++,
        hasSavedGame:false,
      )),
    ));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('title-continue')));
    await tester.pump();
    expect(continueCount,0);
    await tester.tap(find.byKey(const ValueKey('title-new-game')));
    await tester.pump();
    expect(newCount,1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
