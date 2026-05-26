import 'package:bodybuddiesapp/models/subscription.dart';

import 'booking.dart';

class UserModel {
  int credits;
  String creditType;
  bool active;
  List<Booking> bookings;
  List<Subscription> subscriptions;
  String email;
  String name;
  int rewardStamps;
  int weight;

  UserModel(
      {required this.credits,
      required this.bookings,
      required this.subscriptions,
      required this.active,
      required this.creditType,
      required this.email,
      required this.name,
      required this.rewardStamps,
      required this.weight});

  factory UserModel.fromJson(var data) {
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final list = _asList(map['bookings']);
    final subs = _asList(map['subscriptions']);
    return UserModel(
        credits: _asInt(map['credits']),
        bookings: list
            .map((booking) {
              try {
                return Booking.fromJson(booking, "");
              } catch (e) {
                return null;
              }
            })
            .whereType<Booking>()
            .toList(),
        subscriptions: subs
            .map((sub) {
              try {
                return Subscription.fromJson(Map<String, dynamic>.from(sub));
              } catch (e) {
                return null;
              }
            })
            .whereType<Subscription>()
            .toList(),
        active: map['active'] == true,
        creditType: _asString(map['credit_type']),
        email: _asString(map['email']),
        weight: _asInt(map['weight']),
        name: _asString(map['name']),
        rewardStamps: _asInt(map['reward_stamps']));
  }

  static List<dynamic> _asList(dynamic value) {
    return value is List ? value : <dynamic>[];
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    return value?.toString() ?? "";
  }
}
