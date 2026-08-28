import 'package:flutter_test/flutter_test.dart';
import 'package:paper_boat_pulse/main.dart';

void main() {
  testWidgets('renders the Paper Boat Pulse dashboard', (tester) async {
    await tester.pumpWidget(const PulseApp());
    expect(find.text('Pulse dashboard'), findsOneWidget);
    expect(find.text('Weekly momentum'), findsOneWidget);
  });
}
