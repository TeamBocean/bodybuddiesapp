class Booking {
  String id;
  String bookingName;
  String time;
  String date;
  double price;
  String trainer;

  Booking(
      {this.id = '',
      required this.bookingName,
      required this.price,
      required this.time,
      this.trainer = "Mark",
      required this.date});

  factory Booking.fromJson(var data, String id) {
    return Booking(
        id: data['id'] ?? "",
        bookingName: data['name'],
        price: data['price'].toDouble(),
        trainer: data['trainer'] ?? "Mark",
        time: data['time'],
        date: data['date']);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": bookingName,
      "price": price,
      "time": time,
      "trainer": trainer,
      "date": date,
      "id": id
    };
  }
}
