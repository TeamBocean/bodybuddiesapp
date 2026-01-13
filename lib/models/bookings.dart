class Bookings {
  Map list;

  Bookings({required this.list});

  factory Bookings.fromJson(var data) {
    // Handle null data (e.g., when document doesn't exist for a new year)
    if (data == null) {
      return Bookings(list: {});
    }
    return Bookings(list: data as Map);
  }
}
