import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  testWidgets('El juego inicia en lugar del contador predeterminado de Flutter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HermanasGame()));
    expect(find.byType(HermanasGame), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
