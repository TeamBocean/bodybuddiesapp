import 'package:bodybuddiesapp/services/text_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/booking.dart';

class EmailService {
  void sendBookingConfirmationToUser(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await http
        .post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': 'service_bpsye2e',
              'template_id': 'template_eocoarl',
              'user_id': 'k8sIXq9w1NpPrnOGw',
              'accessToken': 'OT3Rt5KH0KdlFroan90hJ',
              'template_params': {
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
              }
            }))
        .then((value) => print(value.body + value.statusCode.toString()));
  }

  void sendSubscriptionConfirmationToUser() async {
    final user = FirebaseAuth.instance.currentUser;

    await http
        .post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': 'service_bpsye2e',
              'template_id': 'template_eocoarl',
              'user_id': 'k8sIXq9w1NpPrnOGw',
              'accessToken': 'OT3Rt5KH0KdlFroan90hJ',
              'template_params': {
                'from_name': "BodyBuddies Team",
                'to_name': FirebaseAuth.instance.currentUser!.displayName,
                'user_email': user!.email,
                'from_email': "markmcquaid54@gmail.com",
                'message':
                    'Thank you for joining Body Buddies, and we look forward to supporting you as you start your fitness journey. Please be advised our Personal Training/Buddy Training 8 & 12 credit Package expires 35 days after your initial booking. Personal Training/Buddy Training 36 credit Package expires 105 days after your initial booking.',
                'reply_to': "markmcquaid54@gmail.com",
              }
            }))
        .then((value) => print(value.body + value.statusCode.toString()));
  }

  void sendBookingConfirmationToMark(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await http
        .post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': 'service_bpsye2e',
              'template_id': 'template_eocoarl',
              'user_id': 'k8sIXq9w1NpPrnOGw',
              'accessToken': 'OT3Rt5KH0KdlFroan90hJ',
              'template_params': {
                'from_name': FirebaseAuth.instance.currentUser!.displayName,
                'to_name': booking!.trainer,
                'user_email': booking.trainer == "Mark"
                    ? "markmcquaid54@gmail.com"
                    : "mandalena.work@gmail.com",
                'from_email': user!.email,
                'message':
                    'Upcoming lesson at: ${booking.time + TextFormat().fixTimeFormat(booking.time)} on ${booking.date} with ${FirebaseAuth.instance.currentUser!.displayName}',
                'reply_to': user.email
              }
            }))
        .then((value) => print(value.body));
  }

  void sendBookingCancellationToMark(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await http.post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': 'service_bpsye2e',
          'template_id': 'template_eocoarl',
          'user_id': 'k8sIXq9w1NpPrnOGw',
          'accessToken': 'OT3Rt5KH0KdlFroan90hJ',
          'template_params': {
            'from_name': FirebaseAuth.instance.currentUser!.displayName,
            'to_name': booking!.trainer,
            'user_email': booking.trainer == "Mark"
                ? "markmcquaid54@gmail.com"
                : "mandalena.work@gmail.com",
            'from_email': user!.email,
            'message':
                'Lesson cancelled at: ${booking.time + TextFormat().fixTimeFormat(booking.time)} on ${booking.date} with ${FirebaseAuth.instance.currentUser!.displayName}',
            'reply_to': user.email
          }
        }));
  }

  void sendPDFToUser(String name) async {
    final user = FirebaseAuth.instance.currentUser;

    await http
        .post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': 'service_bpsye2e',
              'template_id': 'template_09td3c9',
              'user_id': 'k8sIXq9w1NpPrnOGw',
              'accessToken': 'OT3Rt5KH0KdlFroan90hJ',
              'template_params': {
                'to_name': "",
                'user_email': FirebaseAuth.instance.currentUser!.email,
              }
            }))
        .then((value) => print(value.body));
  }
}
