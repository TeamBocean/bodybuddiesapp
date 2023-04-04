import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/services/text_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  void sendBookingConfirmation(Booking? booking) async {
    final user = FirebaseAuth.instance.currentUser;

    UserModel userModel = await CloudFirestore()
        .getUserData(FirebaseAuth.instance.currentUser!.uid);

    await http.post(Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': 'service_4dkli4o',
          'template_id': 'template_idhk9g2',
          'user_id': 'pVIVtNlmmO4AU9CDL',
          'accessToken': 'GeIn3HeDxTAtzzSS16Xsz',
          'template_params': {
            'from_name': "Mark Test",
            'to_name': FirebaseAuth.instance.currentUser!.displayName,
            'user_email': user!.email,
            'from_email': "mahmoudalmahroum3@gmail.com",
            'message':
                'Your lesson is at: ${booking!.time + TextFormat().fixTimeFormat(booking.time)} on ${booking.date}',
            'reply_to': user.email
          }
        }));
  }
}
