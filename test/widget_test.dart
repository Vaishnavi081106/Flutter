import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_boat_pulse/main.dart';

void main() {
  testWidgets('renders the Paper Boat Pulse dashboard', (tester) async {
    await tester.pumpWidget(const PulseApp());
    expect(find.text('Pulse dashboard'), findsOneWidget);
    expect(find.text('Weekly momentum'), findsOneWidget);
  });

  testWidgets('opens the brand story with a Hero transition', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.tap(find.byType(Hero).first);
    await tester.pumpAndSettle();

    expect(find.text('The Pulse idea'), findsOneWidget);
    expect(find.text('Small signals. Clear momentum.'), findsOneWidget);
  });

  testWidgets('opens insights and profile pages from navigation', (tester) async {
    await tester.pumpWidget(const PulseApp());

    await tester.tap(find.byTooltip('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Patterns from your team’s latest activity.'), findsOneWidget);

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your workspace identity and preferences.'), findsOneWidget);
  });

  testWidgets('profile actions toggle notifications and appearance', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly summary notifications are enabled.'), findsOneWidget);
    await tester.tap(find.text('Mute'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly summary muted'), findsOneWidget);

    await tester.tap(find.text('Appearance'));
    await tester.pump();
    expect(find.text('Light theme'), findsOneWidget);
  });
}
