class Bookings {
  Map list;

  Bookings({required this.list});

  factory Bookings.fromJson(var data) {
    return Bookings(list: data);
  }
}
