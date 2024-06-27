class Subscription {
  int credits;
  String date;
  double price;
  String type;

  Subscription({required this.credits, required this.price, required this.date, required this.type});

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
      credits: json['credits'],
      date: json['date'].toString(),
      price: json['price'],
      type: json['type'],
    );
  }
}