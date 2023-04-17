import 'package:bodybuddiesapp/models/bookings.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/email.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking.dart';

class CloudFirestore {
  final reference = FirebaseFirestore.instance;

  Future<bool> isUserExists() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    DocumentSnapshot doc =
        await reference.collection("users").doc(auth.currentUser!.uid).get();

    return doc.exists;
  }

  bool setUserInfo() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      reference.collection("users").doc(auth.currentUser!.uid).set(
          {"credits": 0, "bookings": [], "active": false, "credit_type": ""});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserModel> getUserData(String userID) async {
    DocumentSnapshot doc =
        await reference.collection("users").doc(userID).get();

    return UserModel.fromJson(doc.data());
  }

  Stream<UserModel> streamUserData(String userID) {
    return reference
        .collection("users")
        .doc(userID)
        .snapshots()
        .map((user) => UserModel.fromJson(user));
  }

  Stream<Bookings> streamBookedDates(String userID) {
    return reference
        .collection("bookings")
        .doc(DateTime.now().year.toString())
        .snapshots()
        .map((user) => Bookings.fromJson(user.data()));
  }

  /// Create a booking
  /// Send booking confirmation email to customer
  /// Send booking confirmation email to Mark
  void addUserBooking(Booking booking, String userID) {
    reference.collection("users").doc(userID).update({
      "bookings": FieldValue.arrayUnion([booking.toJson()])
    });
    // EmailService().sendBookingConfirmationToMark(booking);
    EmailService().sendBookingConfirmationToUser(booking);
    addBooking(booking);
  }

  void addBooking(Booking booking) {
    List<String> dateAsList = booking.date.replaceAll("/", ".").split(".");
    reference
        .collection("bookings")
        .doc(DateTime.now().year.toString())
        .update({
      "${dateAsList[1]}.${dateAsList[0]}": FieldValue.arrayUnion([booking.time])
    });
  }

  /// Create a booking
  /// Send booking confirmation email to customer
  /// Send booking confirmation email to Mark
  void addCredits(int credits, String userID, String creditType) {
    reference.collection("users").doc(userID).update({
      "credits": FieldValue.increment(credits),
      "active": true,
      "credit_type": creditType
    });
  }

  /// Decrease user credits
  void decreaseCredits(int credits, String userID) {
    reference.collection("users").doc(userID).update(
        {"credits": FieldValue.increment(-credits)}).whenComplete(() async {
      UserModel userModel =
          await getUserData(FirebaseAuth.instance.currentUser!.uid);
      if (userModel.credits == 0) {
        toggleSubscriptionIsActive(false);
      }
    });
  }

  void toggleSubscriptionIsActive(bool value) {
    reference
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"active": value, "credit_type": ""});
  }
}
