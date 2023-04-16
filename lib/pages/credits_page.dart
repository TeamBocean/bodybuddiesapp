import 'dart:convert';

import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../utils/dimensions.dart';
import '../widgets/medium_text_widget.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({Key? key}) : super(key: key);

  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
        backgroundColor: background,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: background,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20 * 2,
              vertical: Dimensions.height20),
          child: Column(
            children: [
              paymentOptionWidget(350, "8"),
              paymentOptionWidget(550, "12"),
              paymentOptionWidget(1450, "36"),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentOptionWidget(double price, String credits) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height12),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: Dimensions.height12 * 15,
        color: darkGrey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width12, vertical: Dimensions.height12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: "${credits} Credits",
                    fontSize: Dimensions.fontSize18,
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  MediumTextWidget(
                    text: "2 Sessions per week",
                    fontSize: Dimensions.fontSize14,
                    color: Colors.grey,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: "€${price.toStringAsFixed(0)}",
                    fontSize: Dimensions.fontSize28,
                    color: darkGreen,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () {
                          makePayment(price);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: background),
                        child: MediumTextWidget(
                          text: "Purchase",
                          fontSize: Dimensions.fontSize14,
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePayment(double price) async {
    try {
      paymentIntent =
          await createPaymentIntent(price.toStringAsFixed(0), 'EUR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Adnan'))
          .then((value) {});

      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51HjpItIZd5hDXDsaxggZwNzcrnnH3VKyi8n0vMl1wtoCyWyjhZcxdF7Ttd4ZFlLiWqpBG0R50QY39Edn6zZAN21K00BVNQkEV0',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}
