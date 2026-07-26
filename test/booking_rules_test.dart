import 'package:bodybuddiesapp/utils/booking_rules.dart';
import 'package:bodybuddiesapp/models/booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingRules', () {
    test('45 minute sessions block overlapping quarter-hour starts', () {
      expect(BookingRules.sessionsOverlap('14:00', '14:15'), isTrue);
      expect(BookingRules.sessionsOverlap('14:00', '14:30'), isTrue);
      expect(BookingRules.sessionsOverlap('14:00', '14:45'), isFalse);
    });

    test('locks each occupied quarter', () {
      expect(
          BookingRules.occupiedQuarterIds('19:30'), ['1930', '1945', '2000']);
    });
  });

  test('public booking retains its owning user id', () {
    final booking = Booking.fromJson({
      'user_id': 'client-123',
      'name': 'Client',
      'price': 1,
      'time': '14:00',
      'date': '18/7/2026',
    }, 'booking-1');
    expect(booking.userId, 'client-123');
    expect(booking.toJson(), isNot(contains('user_id')));
  });

  test('legacy dates are deterministic and malformed dates are rejected', () {
    final legacy = Booking(
      bookingName: 'Legacy',
      price: 1,
      time: '14:30',
      date: '18/7',
    );
    expect(legacy.getDateTime(), DateTime(2025, 7, 18, 14, 30));

    final invalid = Booking(
      bookingName: 'Invalid',
      price: 1,
      time: '14:30',
      date: '31/2/2026',
    );
    expect(invalid.getDateTime, throwsFormatException);
  });

  test('canonical start timestamp wins over legacy strings', () {
    final start = DateTime(2026, 7, 18, 19, 30);
    final booking = Booking(
      bookingName: 'Canonical',
      price: 1,
      time: 'broken',
      date: 'broken',
      startAt: start,
    );
    expect(booking.getDateTime(), start);
  });
}
