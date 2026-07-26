import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/onboarding_test_helpers.dart';

void main() {
  setUpAll(() async {
    await initOnboardingTests();
  });

  group('OnBoardingPage layout and keyboard', () {
    testWidgets('uses stable keyboard layout settings', (tester) async {
      await pumpOnboardingPage(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.resizeToAvoidBottomInset, isFalse);

      final scrollView = tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(
        scrollView.keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.manual,
      );
    });

    testWidgets('text fields are enabled and expose scroll padding',
        (tester) async {
      await pumpOnboardingPage(tester);

      expect(onboardingTextFields(), findsNWidgets(2));

      for (var index = 0; index < 2; index++) {
        final field =
            tester.widget<TextFormField>(onboardingTextFields().at(index));
        expect(field.enabled, isTrue);

        final textField =
            tester.widget<TextField>(onboardingTextFieldAt(index));
        expect(textField.scrollPadding, const EdgeInsets.only(bottom: 120));
      }
    });

    testWidgets('keeps name field focused when keyboard inset appears',
        (tester) async {
      await pumpOnboardingPage(tester);

      final nameField = onboardingTextFields().at(0);
      await tester.tap(nameField);
      await tester.pump();

      expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);

      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.reset);
      await tester.pump();

      expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);
      expect(find.text('Complete setup'), findsOneWidget);
    });

    testWidgets('moves focus from name to weight on next action',
        (tester) async {
      await pumpOnboardingPage(tester);

      final fields = onboardingTextFields();
      await tester.enterText(fields.at(0), 'Jane Doe');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      final weightEditable = find.descendant(
        of: fields.at(1),
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(weightEditable).focusNode.hasFocus,
        isTrue,
      );
    });

    testWidgets('submits from the weight keyboard action', (tester) async {
      int? submittedWeight;

      await pumpOnboardingPage(
        tester,
        submitUserInfo: (_, weight) async {
          submittedWeight = weight;
          return true;
        },
        sendWelcomeEmail: (_) async {},
      );

      final fields = onboardingTextFields();
      await tester.enterText(fields.at(0), 'Jane Doe');
      await tester.tap(find.widgetWithText(ChoiceChip, 'lb'));
      await tester.enterText(fields.at(1), '165');
      await tester.tap(fields.at(1));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submittedWeight, 75);
      expect(find.text('Your profile is saved.'), findsOneWidget);
    });

    testWidgets('converts the existing value when the unit changes',
        (tester) async {
      await pumpOnboardingPage(tester);

      final fields = onboardingTextFields();
      await tester.enterText(fields.at(1), '75');
      await tester.tap(find.widgetWithText(ChoiceChip, 'lb'));
      await tester.pump();

      expect(find.text('165.3'), findsOneWidget);
      expect(find.text('Weight (lb)'), findsOneWidget);
    });
  });

  group('OnBoardingPage submit flow', () {
    testWidgets('shows retry dialog when setup fails', (tester) async {
      await pumpOnboardingPage(
        tester,
        submitUserInfo: (_, __) async => false,
        sendWelcomeEmail: (_) async {},
      );
      await fillValidOnboardingForm(tester);

      await tester.tap(find.text('Complete setup'));
      await tester.pumpAndSettle();

      expect(find.text('Setup not finished'), findsOneWidget);
      expect(
        find.textContaining('Check your connection and try again'),
        findsOneWidget,
      );
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Complete setup'), findsOneWidget);
    });

    testWidgets('keep editing on retry dialog explains recovery options',
        (tester) async {
      await pumpOnboardingPage(
        tester,
        submitUserInfo: (_, __) async => false,
        sendWelcomeEmail: (_) async {},
      );
      await fillValidOnboardingForm(tester);

      await tester.tap(find.text('Complete setup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(find.text('Connection Issue'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Check your connection, then tap Complete setup'),
        findsOneWidget,
      );
    });

    testWidgets('shows success state after verified setup write',
        (tester) async {
      var continued = false;

      await pumpOnboardingPage(
        tester,
        submitUserInfo: (name, weight) async {
          expect(name, 'Jane Doe');
          expect(weight, 75);
          return true;
        },
        sendWelcomeEmail: (_) async {},
        onContinue: () => continued = true,
      );
      await fillValidOnboardingForm(tester);

      await tester.tap(find.text('Complete setup'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Your profile is saved.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Complete setup'), findsNothing);

      await tester.tap(find.text('Continue'));
      expect(continued, isTrue);
    });

    testWidgets('retries setup from dialog after failure', (tester) async {
      var attempts = 0;

      await pumpOnboardingPage(
        tester,
        submitUserInfo: (_, __) async {
          attempts++;
          return attempts > 1;
        },
        sendWelcomeEmail: (_) async {},
      );
      await fillValidOnboardingForm(tester);

      await tester.tap(find.text('Complete setup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(attempts, 2);
      expect(find.text('Your profile is saved.'), findsOneWidget);
    });
  });
}
