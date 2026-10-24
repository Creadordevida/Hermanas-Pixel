import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('La aplicación carga su juego y no el contador predeterminado', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HermanasGame()));
    expect(find.byType(HermanasGame), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
