/// Model representing a training session booking.
///
/// This class handles date parsing centrally to ensure consistency across the app.
/// Dates can be stored in two formats:
/// - "DD/MM" (legacy format, deterministically mapped to the 2025 dataset)
/// - "DD/MM/YYYY" (full format with year)
class Booking {
  String id;
  String bookingName;
  String time;
  String date;
  double price;
  String trainer;
  String trainerId;
  String userId;
  String recordType;
  String endTime;
  String blockId;
  DateTime? startAt;

  Booking({
    this.id = '',
    this.userId = '',
    required this.bookingName,
    required this.price,
    required this.time,
    this.trainer = "Mark",
    this.trainerId = "",
    this.recordType = "session",
    this.endTime = "",
    this.blockId = "",
    this.startAt,
    required this.date,
  });

  factory Booking.fromJson(var data, String id) {
    return Booking(
      id: data['id'] ?? id,
      userId: data['user_id'] ?? '',
      bookingName: data['name'] ?? "",
      price: (data['price'] ?? 0).toDouble(),
      trainer: data['trainer'] ?? "Mark",
      trainerId: data['trainer_id'] ?? '',
      recordType: data['record_type'] ?? 'session',
      endTime: data['end_time'] ?? '',
      blockId: data['block_id'] ?? '',
      startAt: _readTimestamp(data['start_at']),
      time: data['time'] ?? "",
      date: data['date'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": bookingName,
      "price": price,
      "time": time,
      "trainer": trainer,
      "date": normalizedDate, // Always store with year
      "id": id,
      if (trainerId.isNotEmpty) "trainer_id": trainerId,
      if (startAt != null) "start_at": startAt,
    };
  }

  // ============================================
  // CENTRALIZED DATE HANDLING
  // ============================================

  /// Returns the date with year always included (DD/MM/YYYY format).
  /// Legacy records without a year came from the 2025 dataset.
  String get normalizedDate {
    final parts = date.split('/');
    if (parts.length == 3) {
      return date; // Already has year
    }
    if (parts.length != 2) return date;
    // Legacy format without year - map to its source dataset.
    return "${parts[0]}/${parts[1]}/2025";
  }

  /// Parses the date and time into a DateTime object.
  /// Handles both legacy (DD/MM) and full (DD/MM/YYYY) formats.
  DateTime getDateTime() {
    if (startAt != null) return startAt!.toLocal();
    return _parseLocal(date, time);
  }

  /// Returns just the date portion as DateTime (time set to midnight).
  DateTime getDateOnly() {
    final parsed = startAt?.toLocal() ?? _parseLocal(date, '00:00');
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Returns the year from the booking date.
  int get year {
    return getDateOnly().year;
  }

  /// Returns the month from the booking date.
  int get month {
    return getDateOnly().month;
  }

  /// Returns the day from the booking date.
  int get day {
    return getDateOnly().day;
  }

  /// Returns true if this booking is in the past.
  bool get isPast {
    return getDateTime().isBefore(DateTime.now());
  }

  /// Returns true if this booking is upcoming (in the future).
  bool get isUpcoming {
    return getDateTime().isAfter(DateTime.now());
  }

  /// Checks if this booking matches a specific date (ignoring time).
  bool isOnDate(DateTime targetDate) {
    final bookingDate = getDateOnly();
    return bookingDate.year == targetDate.year &&
        bookingDate.month == targetDate.month &&
        bookingDate.day == targetDate.day;
  }

  /// Checks if this booking is within 24 hours from now.
  bool get isWithin24Hours {
    final difference = getDateTime().difference(DateTime.now());
    return !difference.isNegative && difference <= const Duration(hours: 24);
  }

  bool get isBlock => recordType == 'block';

  static DateTime? _readTimestamp(dynamic value) {
    if (value is DateTime) return value;
    try {
      final converted = value?.toDate();
      return converted is DateTime ? converted : null;
    } catch (_) {
      return null;
    }
  }

  static DateTime _parseLocal(String date, String time) {
    final dateParts = date.split('/');
    final timeParts = time.split(':');
    if ((dateParts.length != 2 && dateParts.length != 3) ||
        timeParts.length != 2) {
      throw FormatException('Invalid booking date/time: $date $time');
    }
    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = dateParts.length == 3 ? int.tryParse(dateParts[2]) : 2025;
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if ([day, month, year, hour, minute].any((part) => part == null)) {
      throw FormatException('Invalid booking date/time: $date $time');
    }
    final parsed = DateTime(year!, month!, day!, hour!, minute!);
    if (parsed.year != year ||
        parsed.month != month ||
        parsed.day != day ||
        parsed.hour != hour ||
        parsed.minute != minute) {
      throw FormatException('Invalid booking date/time: $date $time');
    }
    return parsed;
  }

  @override
  String toString() {
    return 'Booking(id: $id, name: $bookingName, date: $date, time: $time, trainer: $trainer)';
  }
}
