import 'package:bodybuddiesapp/pages/on_boarding_page.dart';
import 'package:bodybuddiesapp/utils/app_theme.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> initOnboardingTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
}

Future<void> pumpOnboardingPage(
  WidgetTester tester, {
  Future<bool> Function(String name, int weight)? submitUserInfo,
  Future<void> Function(String name)? sendWelcomeEmail,
  VoidCallback? onContinue,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) {
          Dimensions.init(context);
          return OnBoardingPage(
            initialName: '',
            submitUserInfo: submitUserInfo,
            sendWelcomeEmail: sendWelcomeEmail,
            onContinue: onContinue,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder onboardingTextFields() {
  return find.descendant(
    of: find.byType(Form),
    matching: find.byType(TextFormField),
  );
}

Finder onboardingTextFieldAt(int index) {
  return find.descendant(
    of: onboardingTextFields().at(index),
    matching: find.byType(TextField),
  );
}

Future<void> fillValidOnboardingForm(WidgetTester tester) async {
  final fields = onboardingTextFields();
  await tester.enterText(fields.at(0), 'Jane Doe');
  await tester.enterText(fields.at(1), '75');
}
