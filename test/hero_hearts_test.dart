import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/hero_hearts.dart';

void main() {
  test('Cinco corazones disponibles y un corazón de daño por impacto', () {
    expect(maxHeroHearts, 5);
    var health = maxHeroHearts;
    for (var i = 4; i >= 0; i--) {
      health = heartsAfterDamage(health);
      expect(health, i);
    }
    expect(heartsAfterDamage(health), 0, reason: 'La vida no puede ser negativa');
    expect(heartsAfterDamage(99), maxHeroHearts, reason: 'La vida jamás supera el máximo');
  });

  Future<void> showLife(WidgetTester tester, int hearts) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: HeroHeartsRow(hearts: hearts))),
    ));
  }

  testWidgets('La interfaz muestra cinco corazones completos al comenzar', (tester) async {
    await showLife(tester, maxHeroHearts);
    expect(find.byIcon(Icons.favorite), findsNWidgets(5));
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byKey(const Key('heart-slot-4')), findsOneWidget);
    expect(tester.getSize(find.byType(HeroHeartsRow)).width, lessThan(101));
  });

  testWidgets('Tras perder dos vidas permanecen cinco huecos, 3 llenos y 2 vacíos', (tester) async {
    await showLife(tester, 3);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
    for(var i=0; i<5; i++) {
      expect(find.byKey(Key('heart-slot-$i')), findsOneWidget);
    }
  });

  testWidgets('Al morir se mantienen cinco posiciones vacías', (tester) async {
    await showLife(tester, 0);
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(5));
  });
}
