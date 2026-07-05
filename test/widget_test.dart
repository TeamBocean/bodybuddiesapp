import 'dart:async';
import 'dart:io';

import 'package:bodybuddiesapp/models/bookings.dart';
import 'package:bodybuddiesapp/pages/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release Android manifest declares internet permission', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(
      manifest,
      contains('android.permission.INTERNET'),
      reason:
          'Release builds need network access for Firebase, Stripe, and EmailJS.',
    );
  });

  testWidgets('auth wrapper keeps onboarding mounted when keyboard appears',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.reset);

    final authController = StreamController<User?>();
    final userDocController =
        StreamController<DocumentSnapshot<Map<String, dynamic>>>();
    addTearDown(authController.close);
    addTearDown(userDocController.close);

    var userDocumentStreamCreations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Wrapper(
          authStateStream: authController.stream,
          userDocumentStreamFor: (uid) {
            expect(uid, 'test-user');
            userDocumentStreamCreations++;
            return userDocController.stream;
          },
          onboardingBuilder: (_) => const _KeyboardProbeOnboarding(),
        ),
      ),
    );

    authController.add(_TestUser());
    await tester.pump();
    userDocController.add(_TestUserDocumentSnapshot({
      'name': '',
      'weight': 0,
    }));
    await tester.pump();

    expect(find.byKey(_KeyboardProbeOnboarding.weightFieldKey), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(userDocumentStreamCreations, 1);

    await tester.tap(find.byKey(_KeyboardProbeOnboarding.weightFieldKey));
    await tester.enterText(
      find.byKey(_KeyboardProbeOnboarding.weightFieldKey),
      '75',
    );
    await tester.pump();

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pump();

    expect(find.text('75'), findsOneWidget);
    expect(find.byKey(_KeyboardProbeOnboarding.weightFieldKey), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(userDocumentStreamCreations, 1);
  });

  test('booking availability accepts dotted and legacy nested Firestore shapes',
      () {
    final bookings = Bookings.fromJson({
      '6.20': ['09:00'],
      '6': {
        '20': ['09:15'],
        '21': ['10:00'],
      },
    });

    expect(bookings.list['6']['20'], ['09:00', '09:15']);
    expect(bookings.list['6']['21'], ['10:00']);
  });
}

class _KeyboardProbeOnboarding extends StatelessWidget {
  static const weightFieldKey = Key('keyboard-probe-weight-field');

  const _KeyboardProbeOnboarding();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TextField(
        key: weightFieldKey,
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class _TestUser implements User {
  @override
  String get uid => 'test-user';

  @override
  String? get email => 'test@example.com';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUserDocumentSnapshot
    implements DocumentSnapshot<Map<String, dynamic>> {
  const _TestUserDocumentSnapshot(this._data);

  final Map<String, dynamic>? _data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _data != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
