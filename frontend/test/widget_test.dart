import 'package:flutter_test/flutter_test.dart';

import 'package:agrosense_ai/app.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const AgroSenseApp());
  });
}
