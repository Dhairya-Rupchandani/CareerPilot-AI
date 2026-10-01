import 'package:flutter_test/flutter_test.dart';
import 'package:careerpilot_ai_new/main.dart';

void main() {
  testWidgets('CareerPilot AI loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CareerPilotApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}