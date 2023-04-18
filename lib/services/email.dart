import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/services/text_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  void sendBookingConfirmationToUser(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await http
        .post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': 'service_qzxeeyw',
              'template_id': 'template_5kq8l6l',
              'user_id': '6j4yPTB5ndFWYGklN',
              'accessToken': '3NWjnYCsx0c9uUfDtNCPz',
              'template_params': {
                'from_name': "BodyBuddies Team",
                'to_name': FirebaseAuth.instance.currentUser!.displayName,
                'user_email': user!.email,
                'from_email': "team.bocean@gmail.com",
                'message':
                    'Thank you for making a booking with Mark at ${booking!.time + TextFormat().fixTimeFormat(booking.time)} ${booking.date}. Please be advised bookings have a minimum 24hr cancellation policy. If you cancel or reschedule this booking with less than 24 hour you will lose the credit.',
                'reply_to': "team.bocean@gmail.com",
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
              'service_id': 'service_qzxeeyw',
              'template_id': 'template_5kq8l6l',
              'user_id': '6j4yPTB5ndFWYGklN',
              'accessToken': '3NWjnYCsx0c9uUfDtNCPz',
              'template_params': {
                'from_name': "BodyBuddies Team",
                'to_name': FirebaseAuth.instance.currentUser!.displayName,
                'user_email': user!.email,
                'from_email': "team.bocean@gmail.com",
                'message':
                    'Thank you for joining Body Buddies, and we look forward to supporting you as you start your fitness journey. Please be advised our Personal Training/Buddy Training 8 & 12 credit Package expires 35 days after your initial booking. Personal Training/Buddy Training 36 credit Package expires 105 days after your initial booking.',
                'reply_to': "team.bocean@gmail.com",
              }
            }))
        .then((value) => print(value.body + value.statusCode.toString()));
  }

  void sendBookingConfirmationToMark(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    await http.post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': 'service_4dkli4o',
          'template_id': 'template_idhk9g2',
          'user_id': 'pVIVtNlmmO4AU9CDL',
          'accessToken': 'GeIn3HeDxTAtzzSS16Xsz',
          'template_params': {
            'from_name': FirebaseAuth.instance.currentUser!.displayName,
            'to_name': "Mark",
            'user_email': "team.bocean@gmail.com",
            'from_email': user!.email,
            'message':
                'Upcoming lesson at: ${booking!.time + TextFormat().fixTimeFormat(booking.time)} on ${booking.date} with ${FirebaseAuth.instance.currentUser!.displayName}',
            'reply_to': user.email
          }
        }));
  }
}
