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
      String month, String day, String documentId, String newName, {int? year}) async {
    try {
      final bookingYear = year ?? DateTime.now().year;
      reference
          .collection("bookings-list")
          .doc(bookingYear.toString())
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
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return UserModel.fromJson({});
    });
  }

  /// Stream booked dates for a specific year
  Stream<Bookings> streamBookedDates(String userID, {int? year}) {
    final bookingYear = year ?? DateTime.now().year;
    return reference
        .collection("bookings")
        .doc(bookingYear.toString())
        .snapshots()
        .map((user) => Bookings.fromJson(user.data()));
  }

  /// Get booked dates for a specific year
  Future<Bookings> getBookedDates(String userID, {int? year}) async {
    final bookingYear = year ?? DateTime.now().year;
    DocumentSnapshot snap = await reference
        .collection("bookings")
        .doc(bookingYear.toString())
        .get();
    return Bookings.fromJson(snap.data());
  }

  /// Stream all bookings for a specific day, month, and year
  Stream<List<Booking>> streamAllBookings(int month, int day, {int? year}) {
    final bookingYear = year ?? DateTime.now().year;
    return reference
        .collection("bookings-list")
        .doc(bookingYear.toString())
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
    // Ensure booking has year in the date
    final bookingWithYear = Booking(
      id: booking.id,
      bookingName: booking.bookingName,
      trainer: booking.trainer,
      price: booking.price,
      time: booking.time,
      date: booking.normalizedDate, // Use normalized date with year
    );
    
    reference.collection("users").doc(userID).update({
      "bookings": FieldValue.arrayUnion([bookingWithYear.toJson()])
    });
    EmailService().sendBookingConfirmationToMark(bookingWithYear);
    EmailService().sendBookingConfirmationToUser(bookingWithYear);
    addBooking(bookingWithYear, month, username);
  }

  void addBooking(Booking booking, int month, String username) {
    // Use centralized date parsing from Booking model
    String day = booking.day.toString();
    String monthStr = booking.month.toString();
    String year = booking.year.toString();

    reference
        .collection("bookings")
        .doc(year)
        .update({
      "$monthStr.$day": FieldValue.arrayUnion([booking.time])
    });

    addPublicBooking(booking, booking.month, username);
  }

  void addPublicBooking(Booking booking, int month, String username) {
    Map<String, dynamic> bookingAsMap = booking.toJson();
    bookingAsMap['name'] = username;
    String year = booking.year.toString();
    
    reference
        .collection("bookings-list")
        .doc(year)
        .collection(month.toString())
        .doc(booking.day.toString())
        .collection("bookings")
        .doc(booking.id)
        .set(bookingAsMap);
  }

  /// Remove a user's booking and handle credit refund
  /// FIXED: Credits are only refunded if cancelled MORE than 24 hours before the session
  void removeUserBooking(Booking booking, String userID) {
    EmailService().sendBookingCancellationToMark(Booking(
        id: booking.id,
        bookingName: booking.bookingName,
        price: booking.price,
        time: booking.time,
        date: booking.date));
    
    reference.collection("users").doc(userID).update({
      "bookings": FieldValue.arrayRemove([booking.toJson()])
    });
    
    removeBooking(booking);
    
    // FIXED: Only refund if >24 hours BEFORE the booking time
    // Previous bug: Used .abs() which meant past bookings always got refunds
    final hoursUntilBooking = booking.getDateTime().difference(DateTime.now()).inHours;
    if (hoursUntilBooking > 24) {
      incrementCredit(1, userID);
    }
  }

  /// DEPRECATED: Use booking.getDateTime() instead
  DateTime getBookingDateTime(String date, String time) {
    List<String> timeAsList = time.split(":");
    List<String> dateAsList = date.split("/");
    return DateTime(
        dateAsList.length == 3 ? int.parse(dateAsList[2]) : DateTime.now().year,
        int.parse(dateAsList[1]),
        int.parse(dateAsList[0]),
        int.parse(timeAsList[0]),
        int.parse(timeAsList[1]));
  }

  /// Remove a booking from the shared collections
  /// FIXED: Uses the booking's actual year, not DateTime.now().year
  void removeBooking(Booking booking) {
    // Use centralized date parsing from Booking model
    String day = booking.day.toString();
    String month = booking.month.toString();
    String year = booking.year.toString();
    
    // Remove from availability tracking
    reference
        .collection("bookings")
        .doc(year)
        .update({
      "$month.$day": FieldValue.arrayRemove([booking.time])
    });

    // Remove from public bookings list
    reference
        .collection("bookings-list")
        .doc(year)
        .collection(month)
        .doc(day)
        .collection("bookings")
        .doc(booking.id)
        .delete();
  }

  /// Add credits to a user's account
  /// Returns true if credits were added successfully
  Future<bool> addCredits(int credits, String userID, String creditType) async {
    try {
      await reference.collection("users").doc(userID).update({
        "credits": FieldValue.increment(credits),
        "active": true,
        "credit_type": creditType
      });
      print('Credits added successfully: $credits credits to user $userID');
      return true;
    } catch (e) {
      print('Error adding credits: $e');
      return false;
    }
  }

  /// Increase user credits (for refunds)
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

  /// Decrease user credits (for bookings)
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
  
  /// Atomically decrease credits using a transaction to prevent race conditions
  /// Returns true if credits were successfully deducted, false otherwise
  Future<bool> decreaseCreditsAtomic(int credits, String userID) async {
    try {
      return await reference.runTransaction<bool>((transaction) async {
        DocumentReference userRef = reference.collection("users").doc(userID);
        DocumentSnapshot userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          return false;
        }
        
        int currentCredits = (userDoc.data() as Map<String, dynamic>)['credits'] ?? 0;
        
        if (currentCredits < credits) {
          return false; // Not enough credits
        }
        
        transaction.update(userRef, {
          "credits": FieldValue.increment(-credits),
        });
        
        return true;
      });
    } catch (e) {
      print('Transaction failed: $e');
      return false;
    }
  }

  void toggleSubscriptionIsActive(bool value) {
    reference
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"active": value, "credit_type": ""});
  }

  /// Add a subscription record to user's history
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
  
  // ============================================
  // EMPLOYEE/ADMIN HELPERS
  // ============================================
  
  /// List of employee emails (case-insensitive matching)
  static const List<String> _employeeEmails = [
    'markmcquaid54@gmail.com',
    'mandalena.work@gmail.com',
  ];
  
  /// List of developer emails for debugging access
  static const List<String> _developerEmails = [
    'mahmoud.al808@gmail.com',
  ];
  
  /// Main admin display name
  static const String _mainAdminName = 'BODY BUDDIES HEALTH & FITNESS';
  
  /// Check if the current user is an employee (trainer)
  bool isEmployee() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final email = user.email?.toLowerCase() ?? '';
    final displayName = user.displayName ?? '';
    
    // Check if main admin
    if (displayName == _mainAdminName) return true;
    
    // Check if developer
    if (_developerEmails.contains(email)) return true;
    
    // Check if employee email
    return _employeeEmails.contains(email);
  }
  
  /// Check if current user is a developer (for debugging access)
  bool isDeveloper() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final email = user.email?.toLowerCase() ?? '';
    return _developerEmails.contains(email);
  }
  
  /// Check if current user is the main admin
  bool isMainAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final displayName = user.displayName ?? '';
    return displayName == _mainAdminName;
  }
  
  /// Get the trainer name for the current employee
  /// Returns null if not an employee
  String? getEmployeeTrainerName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    final email = user.email?.toLowerCase() ?? '';
    final displayName = user.displayName ?? '';
    
    // Main admin sees all as "Mark"
    if (displayName == _mainAdminName) return null; // null = see all
    
    // Developers see all
    if (_developerEmails.contains(email)) return null;
    
    // Map employee emails to trainer names
    if (email == 'markmcquaid54@gmail.com') return 'Mark';
    if (email == 'mandalena.work@gmail.com') return 'Mandalena';
    
    // Default: use display name
    return displayName;
  }
}
