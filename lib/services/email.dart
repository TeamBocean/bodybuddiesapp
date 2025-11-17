import 'dart:convert';

import 'package:bodybuddiesapp/services/text_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/booking.dart';

class EmailService {
  static final Uri _emailJsEndpoint =
      Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

  Map<String, dynamic> _emailJsPayload(
      {required String templateId,
      required Map<String, dynamic> templateParams}) {
    final serviceId = dotenv.env['EMAILJS_SERVICE_ID'];
    final userId = dotenv.env['EMAILJS_USER_ID'];
    final accessToken = dotenv.env['EMAILJS_ACCESS_TOKEN'];

    if ((serviceId ?? '').isEmpty ||
        (userId ?? '').isEmpty ||
        (accessToken ?? '').isEmpty) {
      throw Exception(
          'Missing EmailJS configuration. Please set EMAILJS_SERVICE_ID, '
          'EMAILJS_USER_ID, and EMAILJS_ACCESS_TOKEN in .env');
    }

    return {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'accessToken': accessToken,
      'template_params': templateParams,
    };
  }

  Future<void> _postEmail(Map<String, dynamic> payload) async {
    await http
        .post(_emailJsEndpoint,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload))
        .then((value) => print(value.body + value.statusCode.toString()));
  }

  void sendBookingConfirmationToUser(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await _postEmail(_emailJsPayload(
      templateId: 'template_eocoarl',
      templateParams: {
        'from_name': "BodyBuddies Team",
        'name': booking!.trainer,
        'to_name': FirebaseAuth.instance.currentUser!.displayName,
        'user_email': user!.email,
        'from_email': booking.trainer == "Mark"
            ? "markmcquaid54@gmail.com"
            : "mandalena.work@gmail.com",
        'message':
            'Thank you for making a booking with ${booking.trainer} at ${booking.time + TextFormat().fixTimeFormat(booking.time)} ${booking.date}. Please be advised bookings have a minimum 24hr cancellation policy. If you cancel or reschedule this booking with less than 24 hour you will lose the credit.',
        'reply_to': booking.trainer == "Mark"
            ? "markmcquaid54@gmail.com"
            : "mandalena.work@gmail.com",
      },
    ));
  }

  void sendSubscriptionConfirmationToUser() async {
    final user = FirebaseAuth.instance.currentUser;

    await _postEmail(_emailJsPayload(
      templateId: 'template_eocoarl',
      templateParams: {
        'from_name': "BodyBuddies Team",
        'to_name': FirebaseAuth.instance.currentUser!.displayName,
        'user_email': user!.email,
        'from_email': "markmcquaid54@gmail.com",
        'message':
            'Thank you for joining Body Buddies, and we look forward to supporting you as you start your fitness journey. Please be advised our Personal Training/Buddy Training 8 & 12 credit Package expires 35 days after your initial booking. Personal Training/Buddy Training 36 credit Package expires 105 days after your initial booking.',
        'reply_to': "markmcquaid54@gmail.com",
      },
    ));
  }

  void sendBookingConfirmationToMark(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await _postEmail(_emailJsPayload(
      templateId: 'template_eocoarl',
      templateParams: {
        'from_name': FirebaseAuth.instance.currentUser!.displayName,
        'to_name': booking!.trainer,
        'user_email': booking.trainer == "Mark"
            ? "markmcquaid54@gmail.com"
            : "mandalena.work@gmail.com",
        'from_email': user!.email,
        'message':
            'Upcoming lesson at: ${booking.time + TextFormat().fixTimeFormat(booking.time)} on ${booking.date} with ${FirebaseAuth.instance.currentUser!.displayName}',
        'reply_to': user.email
      },
    ));
  }

  void sendBookingCancellationToMark(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await _postEmail(_emailJsPayload(
      templateId: 'template_eocoarl',
      templateParams: {
        'from_name': FirebaseAuth.instance.currentUser!.displayName,
        'to_name': booking!.trainer,
        'user_email': booking.trainer == "Mark"
            ? "markmcquaid54@gmail.com"
            : "mandalena.work@gmail.com",
        'from_email': user!.email,
        'message':
            'Lesson cancelled at: ${booking.time + TextFormat().fixTimeFormat(booking.time)} on ${booking.date} with ${FirebaseAuth.instance.currentUser!.displayName}',
        'reply_to': user.email
      },
    ));
  }

  void sendPDFToUser(String name) async {
    final user = FirebaseAuth.instance.currentUser;

    await _postEmail(_emailJsPayload(
      templateId: 'template_09td3c9',
      templateParams: {
        'to_name': "",
        'user_email': FirebaseAuth.instance.currentUser!.email,
      },
    ));
  }
}
