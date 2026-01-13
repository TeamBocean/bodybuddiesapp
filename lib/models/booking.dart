/// Model representing a training session booking.
/// 
/// This class handles date parsing centrally to ensure consistency across the app.
/// Dates can be stored in two formats:
/// - "DD/MM" (legacy format, year inferred as current year)
/// - "DD/MM/YYYY" (full format with year)
class Booking {
  String id;
  String bookingName;
  String time;
  String date;
  double price;
  String trainer;

  Booking({
    this.id = '',
    required this.bookingName,
    required this.price,
    required this.time,
    this.trainer = "Mark",
    required this.date,
  });

  factory Booking.fromJson(var data, String id) {
    return Booking(
      id: data['id'] ?? "",
      bookingName: data['name'] ?? "",
      price: (data['price'] ?? 0).toDouble(),
      trainer: data['trainer'] ?? "Mark",
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
    };
  }

  // ============================================
  // CENTRALIZED DATE HANDLING
  // ============================================

  /// Returns the date with year always included (DD/MM/YYYY format).
  /// If the date doesn't have a year, it infers based on context:
  /// - For future dates, uses current year
  /// - For past dates, uses current year (assumes recent booking)
  String get normalizedDate {
    List<String> parts = date.split('/');
    if (parts.length == 3) {
      return date; // Already has year
    }
    // Legacy format without year - add current year
    // Note: This could be made smarter by inferring based on current date
    return "${parts[0]}/${parts[1]}/${DateTime.now().year}";
  }

  /// Parses the date and time into a DateTime object.
  /// Handles both legacy (DD/MM) and full (DD/MM/YYYY) formats.
  DateTime getDateTime() {
    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = dateParts.length == 3 
        ? int.parse(dateParts[2]) 
        : DateTime.now().year;

    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    return DateTime(year, month, day, hour, minute);
  }

  /// Returns just the date portion as DateTime (time set to midnight).
  DateTime getDateOnly() {
    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = dateParts.length == 3 
        ? int.parse(dateParts[2]) 
        : DateTime.now().year;

    return DateTime(year, month, day);
  }

  /// Returns the year from the booking date.
  int get year {
    List<String> dateParts = date.split('/');
    return dateParts.length == 3 
        ? int.parse(dateParts[2]) 
        : DateTime.now().year;
  }

  /// Returns the month from the booking date.
  int get month {
    List<String> dateParts = date.split('/');
    return int.parse(dateParts[1]);
  }

  /// Returns the day from the booking date.
  int get day {
    List<String> dateParts = date.split('/');
    return int.parse(dateParts[0]);
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
    final hoursUntilBooking = getDateTime().difference(DateTime.now()).inHours;
    return hoursUntilBooking.abs() <= 24;
  }

  @override
  String toString() {
    return 'Booking(id: $id, name: $bookingName, date: $date, time: $time, trainer: $trainer)';
  }
}
