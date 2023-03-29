class Booking {
  String bookingName;
  String time;
  String date;
  double price;

  Booking(
      {required this.bookingName,
      required this.price,
      required this.time,
      required this.date});

  factory Booking.fromJson(var data) {
    return Booking(
        bookingName: data['name'],
        price: data['price'].toDouble(),
        time: data['time'],
        date: data['date']);
  }

  Map<String, dynamic> toJson() {
    return {"name": bookingName, "price": price, "time": time, "date": date};
  }
}
