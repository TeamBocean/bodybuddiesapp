class Booking {
  String id;
  String bookingName;
  String time;
  String date;
  double price;

  Booking(
      {this.id = '',
      required this.bookingName,
      required this.price,
      required this.time,
      required this.date});

  factory Booking.fromJson(var data, String id) {
    return Booking(
        id: data['id'],
        bookingName: data['name'],
        price: data['price'].toDouble(),
        time: data['time'],
        date: data['date']);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": bookingName,
      "price": price,
      "time": time,
      "date": date,
      "id": id
    };
  }
}
