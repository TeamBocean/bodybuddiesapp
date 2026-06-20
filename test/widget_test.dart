import 'dart:io';

import 'package:bodybuddiesapp/models/bookings.dart';
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
