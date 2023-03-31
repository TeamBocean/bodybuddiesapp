import 'package:bodybuddiesapp/models/user.dart';
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
      reference.collection("users").doc(auth.currentUser!.uid).set({
        "credits": 0,
        "bookings": [],
      });
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

  void addBooking(Booking booking, String userID) {
    reference.collection("users").doc(userID).update({
      "bookings": FieldValue.arrayUnion([booking.toJson()])
    });
  }
}
