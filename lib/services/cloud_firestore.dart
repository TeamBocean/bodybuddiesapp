import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/utils/onboarding_user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking.dart';
import 'booking_api.dart';

enum BookingResult { success, noCredits, conflict, failed }

class CloudFirestore {
  final reference = FirebaseFirestore.instance;

  Future<bool> isUserExists() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    DocumentSnapshot doc =
        await reference.collection("users").doc(auth.currentUser!.uid).get();

    return doc.exists;
  }

  /// Create user document in Firestore with retry logic
  /// Returns true if successful, false otherwise
  Future<bool> setUserInfo(String name, int weight, {int retries = 3}) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      print('ERROR: No authenticated user found');
      return false;
    }

    final userId = auth.currentUser!.uid;
    final docRef = reference.collection("users").doc(userId);
    final email = auth.currentUser!.email?.toLowerCase() ?? "";

    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        print(
            'Creating user document for $userId (attempt ${attempt + 1}/$retries)');

        final existingDoc = await docRef.get();
        final userData = buildOnboardingUserData(
          documentExists: existingDoc.exists,
          name: name,
          weight: weight,
          email: email,
        );
        userData["onboarding_completed_at"] = FieldValue.serverTimestamp();

        await docRef.set(userData, SetOptions(merge: true));

        final doc = await docRef.get();
        if (isOnboardingWriteVerified(doc.data())) {
          print('✅ User document created successfully for $userId');
          return true;
        } else {
          print(
              '⚠️  Document creation verification failed (attempt ${attempt + 1})');
        }
      } catch (e) {
        print(
            '❌ Error creating user document (attempt ${attempt + 1}/$retries): $e');

        // If this is the last attempt, return false
        if (attempt == retries - 1) {
          print(
              'CRITICAL: Failed to create user document after $retries attempts');
          return false;
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }

    return false;
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
      String month, String day, String documentId, String newName,
      {int? year}) async {
    try {
      final bookingYear = year ?? DateTime.now().year;
      await BookingApi().renameSession(
        sessionId: documentId,
        date: DateTime(bookingYear, int.parse(month), int.parse(day)),
        newName: newName,
      );
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
    return reference.collection("users").doc(userID).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return UserModel.fromJson({});
    });
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

  Stream<List<Booking>> streamDayAvailability(int month, int day, {int? year}) {
    final targetYear = year ?? DateTime.now().year;
    return reference
        .collection('trainer-day-slots')
        .doc(targetYear.toString())
        .collection(month.toString())
        .doc(day.toString())
        .collection('slots')
        .snapshots()
        .map((event) => event.docs
            .map((document) => Booking.fromJson(document.data(), document.id))
            .toList());
  }

  /// Cancels through the authoritative booking command. The server owns lock
  /// release, projections, refund policy, and idempotency.
  Future<void> removeUserBooking(Booking booking, String userID) async {
    await BookingApi().cancelSession(booking: booking, userId: userID);
  }

  Future<List<dynamic>> getAllPTs() async {
    QuerySnapshot snapshot =
        await reference.collection("personal_trainers").get();
    return snapshot.docs.map((pt) => pt.data()).toList();
  }

  /// Reserves a trainer-specific 45-minute session and consumes one credit in
  /// the same transaction.
  Future<BookingResult> bookSlotAtomic({
    required Booking booking,
    required String userID,
    required int month,
    required String username,
    required String userEmail,
  }) async {
    try {
      await BookingApi().createSession(booking: booking, userId: userID);
      return BookingResult.success;
    } on BookingCommandException catch (error) {
      if (error.code == 'no_credits') return BookingResult.noCredits;
      if (error.code == 'conflict' ||
          error.code == 'outside_schedule' ||
          error.code == 'past_session') {
        return BookingResult.conflict;
      }
      return BookingResult.failed;
    }
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
