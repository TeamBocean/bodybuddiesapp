import 'booking.dart';

class UserModel {
  int credits;
  String creditType;
  bool active;
  List<Booking> bookings;

  UserModel(
      {required this.credits,
      required this.bookings,
      required this.active,
      required this.creditType});

  factory UserModel.fromJson(var data) {
    List<dynamic> list = data['bookings'];

    return UserModel(
        credits: data['credits'],
        bookings: list.map((booking) => Booking.fromJson(booking)).toList(),
        active: data['active'],
        creditType: data['credit_type']);
  }
}
