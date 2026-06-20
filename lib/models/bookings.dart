class Bookings {
  Map list;

  Bookings({required this.list});

  factory Bookings.fromJson(var data) {
    if (data == null) {
      return Bookings(list: {});
    }
    return Bookings(list: normalizeAvailabilityMap(data as Map));
  }

  static Map<String, Map<String, List<dynamic>>> normalizeAvailabilityMap(
      Map source) {
    final normalized = <String, Map<String, List<dynamic>>>{};

    void addTime(String month, String day, dynamic value) {
      if (value is! Iterable) return;
      final monthMap =
          normalized.putIfAbsent(month, () => <String, List<dynamic>>{});
      final dayList = monthMap.putIfAbsent(day, () => <dynamic>[]);
      for (final time in value) {
        if (!dayList.contains(time)) {
          dayList.add(time);
        }
      }
    }

    source.forEach((key, value) {
      final keyText = key.toString();
      final dottedParts = keyText.split('.');
      if (dottedParts.length == 2) {
        addTime(dottedParts[0], dottedParts[1], value);
        return;
      }

      if (value is Map) {
        value.forEach((day, times) {
          addTime(keyText, day.toString(), times);
        });
      }
    });

    return normalized;
  }
}
