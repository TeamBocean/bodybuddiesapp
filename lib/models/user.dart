import 'package:bodybuddiesapp/models/subscription.dart';

import 'booking.dart';

class UserModel {
  int credits;
  String creditType;
  bool active;
  List<Booking> bookings;
  List<Subscription> subscriptions;
  String name;
  int weight;

  UserModel(
      {required this.credits,
      required this.bookings,
      required this.subscriptions,
      required this.active,
      required this.creditType,
      required this.name,
      required this.weight});

  factory UserModel.fromJson(var data) {
    data = data ?? {};
    List<dynamic> list = data['bookings'] ?? [];
    List<dynamic> subs = [];
    try {
      subs = data['subscriptions'] ?? [];
    } catch (e) {
      subs = [];
      print(e);
    }
    return UserModel(
        credits: data['credits'] ?? 0,
        bookings: list.map((booking) => Booking.fromJson(booking, "")).toList(),
        subscriptions: subs.isEmpty
            ? []
            : subs.map((sub) => Subscription.fromJson(sub)).toList(),
        active: data['active'] ?? false,
        creditType: data['credit_type'] ?? "",
        weight: data['weight'] ?? 0,
        name: data['name'] ?? "");
  }
}
