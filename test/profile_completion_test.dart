import 'package:bodybuddiesapp/utils/profile_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasCompletedProfile', () {
    test('returns false for missing user data', () {
      expect(hasCompletedProfile(null), isFalse);
      expect(hasCompletedProfile({}), isFalse);
    });

    test('returns true when profile_completed is true', () {
      expect(
        hasCompletedProfile({
          'profile_completed': true,
        }),
        isTrue,
      );
    });

    test('returns true for legacy docs with valid name and weight', () {
      expect(
        hasCompletedProfile({
          'name': 'Jane Doe',
          'weight': 75,
        }),
        isTrue,
      );
      expect(
        hasCompletedProfile({
          'name': 'Jane Doe',
          'weight': '80',
        }),
        isTrue,
      );
    });

    test('returns false for incomplete legacy docs', () {
      expect(
        hasCompletedProfile({
          'name': 'J',
          'weight': 75,
        }),
        isFalse,
      );
      expect(
        hasCompletedProfile({
          'name': 'Jane Doe',
          'weight': 0,
        }),
        isFalse,
      );
    });
  });

  group('parseProfileWeight', () {
    test('parses numeric and string weights', () {
      expect(parseProfileWeight(75), 75);
      expect(parseProfileWeight(75.0), 75);
      expect(parseProfileWeight('82'), 82);
      expect(parseProfileWeight('invalid'), 0);
    });
  });
}
