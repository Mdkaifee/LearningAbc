import 'package:flutter_test/flutter_test.dart';

import 'package:abc_learning/app.dart';
import 'package:abc_learning/screens/main_menu_screen.dart';

void main() {
  testWidgets('App shows splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const AbcLearningApp());

    expect(find.byType(MainMenuScreen), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MainMenuScreen), findsOneWidget);
  });
}
