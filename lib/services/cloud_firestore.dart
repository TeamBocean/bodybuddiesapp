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

  bool setUserInfo(String name, int weight) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      reference.collection("users").doc(auth.currentUser!.uid).set({
        "credits": 0,
        "bookings": [],
        "active": false,
        "credit_type": "",
        "name": name,
        "weight": weight
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool deleteUser() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      reference.collection("users").doc(auth.currentUser!.uid).delete();

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool updateUserName(String value) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      reference
          .collection("users")
          .doc(auth.currentUser!.uid)
          .update({"name": value});

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateBookingName(
      String month, String day, String documentId, String newName) async {
    try {
      reference
          .collection("bookings-list")
          .doc(DateTime.now().year.toString())
          .collection(month)
          .doc(day)
          .collection("bookings")
          .doc(documentId)
          .update({"name": newName});

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool updateUserWeight(int value) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      reference
          .collection("users")
          .doc(auth.currentUser!.uid)
          .update({"weight": value});

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

  Future<Bookings> getBookedDates(String userID) async {
    DocumentSnapshot snap = await reference
        .collection("bookings")
        .doc(DateTime.now().year.toString())
        .get();
    return Bookings.fromJson(snap.data());
  }

  Stream<List<Booking>> streamAllBookings(int month, int day) {
    return reference
        .collection("bookings-list")
        .doc(DateTime.now().year.toString())
        .collection(month.toString())
        .doc(day.toString())
        .collection("bookings")
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Booking.fromJson(e.data(), e.id)).toList());
  }

  /// Create a booking
  /// Send booking confirmation email to customer
  /// Send booking confirmation email to Mark
  void addUserBooking(
      Booking booking, String userID, int month, String username) {
    reference.collection("users").doc(userID).update({
      "bookings": FieldValue.arrayUnion([booking.toJson()])
    });
    EmailService().sendBookingConfirmationToMark(booking);
    EmailService().sendBookingConfirmationToUser(booking);
    addBooking(booking, month, username);
  }

  void addBooking(Booking booking, int month, String username) {
    List<String> dateAsList = booking.date.replaceAll("/", ".").split(".");
    reference
        .collection("bookings")
        .doc(DateTime.now().year.toString())
        .update({
      "${dateAsList[1]}.${dateAsList[0]}": FieldValue.arrayUnion([booking.time])
    });

    addPublicBooking(booking, month, username);
  }

  void addPublicBooking(Booking booking, int month, String username) {
    Map<String, dynamic> bookingAsMap = booking.toJson();
    bookingAsMap['name'] = username;
    reference
        .collection("bookings-list")
        .doc(DateTime.now().year.toString())
        .collection(month.toString())
        .doc(booking.date.split("/").first)
        .collection("bookings")
        .doc(booking.id)
        .set(bookingAsMap);
  }

  void removeUserBooking(Booking booking, String userID) {
    EmailService().sendBookingCancellationToMark(new Booking(
        id: booking.id,
        bookingName: booking.bookingName,
        price: booking.price,
        time: booking.time,
        date: booking.date));
    reference.collection("users").doc(userID).update({
      "bookings": FieldValue.arrayRemove([booking.toJson()])
    });
    // EmailService().sendBookingConfirmationToUser(booking);
    removeBooking(booking);
    if (DateTime.now()
            .difference(getBookingDateTime(booking.date, booking.time))
            .inHours
            .abs() >
        24) {
      incrementCredit(1, userID);
    }
  }

  DateTime getBookingDateTime(String date, String time) {
    List<String> timeAsList = time.split(":");
    List<String> dateAsList = date.split("/");
    return DateTime(
        DateTime.now().year,
        int.parse(dateAsList[1]),
        int.parse(dateAsList[0]),
        int.parse(timeAsList[0]),
        int.parse(timeAsList[1]));
  }

  void removeBooking(Booking booking) {
    List<String> dateAsList = booking.date.replaceAll("/", ".").split(".");
    DateTime dateTime = getBookingDateTime(booking.date, booking.time);
    reference
        .collection("bookings")
        .doc(DateTime.now().year.toString())
        .update({
      "${dateAsList[1]}.${dateAsList[0]}":
          FieldValue.arrayRemove([booking.time])
    });

    reference
        .collection("bookings-list")
        .doc(dateTime.year.toString())
        .collection(dateTime.month.toString())
        .doc(dateTime.day.toString())
        .collection("bookings")
        .doc(booking.id)
        .delete();
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
  void incrementCredit(int credits, String userID) {
    reference.collection("users").doc(userID).update(
        {"credits": FieldValue.increment(credits)}).whenComplete(() async {
      UserModel userModel =
          await getUserData(FirebaseAuth.instance.currentUser!.uid);
      if (userModel.credits == 0) {
        toggleSubscriptionIsActive(false);
      }
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

  /// Create a booking
  /// Send booking confirmation email to customer
  /// Send booking confirmation email to Mark
  void addUserSubscription(
      String userID, int credits, String subscription, double price) {
    reference.collection("users").doc(userID).update({
      "subscriptions": FieldValue.arrayUnion([
        {
          "date": DateTime.now(),
          "credits": credits,
          "type": subscription,
          "price": price
        }
      ])
    });
  }

  Future<List<dynamic>> getAllPTs() async {
    QuerySnapshot snapshot =
        await reference.collection("personal_trainers").get();
    return snapshot.docs.map((pt) => pt.data()).toList();
  }
}
