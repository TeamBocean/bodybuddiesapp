class Subscription {
  int credits;
  String date;
  double price;
  String type;

  Subscription(
      {required this.credits,
      required this.price,
      required this.date,
      required this.type});

  Map<String, dynamic> toJson() {
    return {
      'credits': credits,
      'date': date,
      'price': price,
      'type': type,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      credits: _asInt(json['credits']),
      date: json['date'].toString(),
      price: _asDouble(json['price']),
      type: json['type']?.toString() ?? "",
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }
}
