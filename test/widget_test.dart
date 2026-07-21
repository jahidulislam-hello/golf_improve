import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_training_app/views/screens/onboarding/onboarding/onboarding_card.dart';
import 'package:golf_training_app/views/screens/onboarding/onboarding/onboarding_page_data.dart';

void main() {
  testWidgets('onboarding card fits narrow screens with large text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(280, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: OnboardingCard(
            data: onboardingPages.first,
            currentIndex: 0,
            pageCount: onboardingPages.length,
            onSkip: () {},
            onContinue: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GOLFIMPROVE'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}