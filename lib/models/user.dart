import 'booking.dart';

class UserModel {
  int credits;
  List<Booking> bookings;

  UserModel({required this.credits, required this.bookings});

  factory UserModel.fromJson(var data) {

    List<dynamic> list = data['bookings'];

    return UserModel(
        credits: data['credits'],
        bookings: list.map((booking) => Booking.fromJson(booking)).toList());
  }
}
