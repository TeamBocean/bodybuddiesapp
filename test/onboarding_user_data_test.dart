import 'package:bodybuddiesapp/utils/onboarding_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildOnboardingUserData', () {
    test('new users receive account defaults', () {
      final data = buildOnboardingUserData(
        documentExists: false,
        name: 'Jane Doe',
        weight: 75,
        email: 'Jane@Example.com',
      );

      expect(data['name'], 'Jane Doe');
      expect(data['weight'], 75);
      expect(data['profile_completed'], isTrue);
      expect(data['email'], 'jane@example.com');
      expect(data['credits'], 0);
      expect(data['bookings'], isEmpty);
      expect(data['subscriptions'], isEmpty);
      expect(data['active'], isFalse);
      expect(data['credit_type'], '');
    });

    test('existing partial docs only receive profile fields', () {
      final data = buildOnboardingUserData(
        documentExists: true,
        name: 'Jane Doe',
        weight: 75,
        email: 'jane@example.com',
      );

      expect(data.keys,
          containsAll(['name', 'weight', 'profile_completed', 'email']));
      expect(data.keys, isNot(contains('credits')));
      expect(data.keys, isNot(contains('bookings')));
      expect(data.keys, isNot(contains('subscriptions')));
      expect(data.keys, isNot(contains('active')));
      expect(data.keys, isNot(contains('credit_type')));
    });
  });

  group('isOnboardingWriteVerified', () {
    test('returns true when profile is complete', () {
      expect(
        isOnboardingWriteVerified({
          'name': 'Jane Doe',
          'weight': 75,
          'profile_completed': true,
        }),
        isTrue,
      );
    });

    test('returns false for missing or blank profile data', () {
      expect(isOnboardingWriteVerified(null), isFalse);
      expect(
        isOnboardingWriteVerified({
          'name': ' ',
          'weight': 75,
          'profile_completed': true,
        }),
        isFalse,
      );
      expect(
        isOnboardingWriteVerified({
          'name': 'Jane Doe',
          'weight': 75,
          'profile_completed': false,
        }),
        isFalse,
      );
      expect(
        isOnboardingWriteVerified({
          'name': 'Jane Doe',
          'profile_completed': true,
        }),
        isFalse,
      );
      expect(
        isOnboardingWriteVerified({
          'name': 'Jane Doe',
          'weight': 0,
          'profile_completed': true,
        }),
        isFalse,
      );
    });
  });
}
