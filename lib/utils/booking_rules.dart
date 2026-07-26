class BookingRules {
  static const int sessionMinutes = 45;

  static int minutesSinceMidnight(String time) {
    final parts = time.split(':');
    if (parts.length != 2) throw FormatException('Expected HH:mm', time);
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Invalid time', time);
    }
    return hour * 60 + minute;
  }

  static bool sessionsOverlap(String firstStart, String secondStart) {
    return (minutesSinceMidnight(firstStart) -
                minutesSinceMidnight(secondStart))
            .abs() <
        sessionMinutes;
  }

  static List<String> occupiedQuarterIds(String startTime) {
    final start = minutesSinceMidnight(startTime);
    return [0, 15, 30].map((offset) {
      final minutes = start + offset;
      final hour = (minutes ~/ 60).toString().padLeft(2, '0');
      final minute = (minutes % 60).toString().padLeft(2, '0');
      return '$hour$minute';
    }).toList(growable: false);
  }
}
