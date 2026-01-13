import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for migrating booking data to include year in dates.
/// 
/// The legacy booking format stored dates as "DD/MM" without the year.
/// This migration adds the year to all bookings, defaulting to 2025 for
/// bookings created before 2026.
class BookingMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Migration result tracking
  int _bookingsUpdated = 0;
  int _bookingsAlreadyMigrated = 0;
  int _usersProcessed = 0;
  List<String> _errors = [];

  /// Run the migration in dry-run mode (no actual changes)
  Future<MigrationResult> dryRun() async {
    return _runMigration(dryRun: true);
  }

  /// Run the actual migration
  Future<MigrationResult> migrate() async {
    return _runMigration(dryRun: false);
  }

  Future<MigrationResult> _runMigration({required bool dryRun}) async {
    _bookingsUpdated = 0;
    _bookingsAlreadyMigrated = 0;
    _usersProcessed = 0;
    _errors = [];

    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      
      for (final userDoc in usersSnapshot.docs) {
        try {
          await _migrateUserBookings(userDoc, dryRun: dryRun);
          _usersProcessed++;
        } catch (e) {
          _errors.add('Error processing user ${userDoc.id}: $e');
        }
      }

      return MigrationResult(
        success: _errors.isEmpty,
        bookingsUpdated: _bookingsUpdated,
        bookingsAlreadyMigrated: _bookingsAlreadyMigrated,
        usersProcessed: _usersProcessed,
        errors: _errors,
        dryRun: dryRun,
      );
    } catch (e) {
      _errors.add('Migration failed: $e');
      return MigrationResult(
        success: false,
        bookingsUpdated: _bookingsUpdated,
        bookingsAlreadyMigrated: _bookingsAlreadyMigrated,
        usersProcessed: _usersProcessed,
        errors: _errors,
        dryRun: dryRun,
      );
    }
  }

  Future<void> _migrateUserBookings(DocumentSnapshot userDoc, {required bool dryRun}) async {
    final data = userDoc.data() as Map<String, dynamic>?;
    if (data == null) return;

    final bookings = data['bookings'] as List<dynamic>? ?? [];
    if (bookings.isEmpty) return;

    List<Map<String, dynamic>> updatedBookings = [];
    bool hasChanges = false;

    for (final booking in bookings) {
      final bookingMap = Map<String, dynamic>.from(booking as Map);
      final date = bookingMap['date'] as String? ?? '';

      if (date.isEmpty) continue;

      final parts = date.split('/');
      
      if (parts.length == 2) {
        // Legacy format without year - add year
        // Determine the appropriate year based on the booking date
        final year = _inferYear(parts);
        bookingMap['date'] = '${parts[0]}/${parts[1]}/$year';
        hasChanges = true;
        _bookingsUpdated++;
      } else if (parts.length == 3) {
        // Already has year
        _bookingsAlreadyMigrated++;
      }
      
      updatedBookings.add(bookingMap);
    }

    if (hasChanges && !dryRun) {
      await _firestore.collection('users').doc(userDoc.id).update({
        'bookings': updatedBookings,
      });
    }
  }

  /// Infer the year for a legacy booking date.
  /// 
  /// Logic:
  /// - If we're in January 2026 and the booking is for month 12, it's likely 2025
  /// - Otherwise, use 2025 as default for legacy bookings
  int _inferYear(List<String> dateParts) {
    final now = DateTime.now();
    final bookingMonth = int.parse(dateParts[1]);
    
    // If current year is 2026+ and booking month is later in the year than now,
    // and we're early in the year, it might be from last year
    if (now.year >= 2026) {
      // Most legacy bookings should be from 2025
      // But if we're in early 2026 and see a booking for Dec, it's 2025
      if (now.month <= 3 && bookingMonth >= 10) {
        return 2025;
      }
      // If the booking month is far in the past compared to now, it's likely 2025
      if (bookingMonth < now.month - 6) {
        return 2025;
      }
      // Default to 2025 for safety - legacy bookings were before 2026
      return 2025;
    }
    
    return now.year;
  }
}

/// Result of a migration operation
class MigrationResult {
  final bool success;
  final int bookingsUpdated;
  final int bookingsAlreadyMigrated;
  final int usersProcessed;
  final List<String> errors;
  final bool dryRun;

  MigrationResult({
    required this.success,
    required this.bookingsUpdated,
    required this.bookingsAlreadyMigrated,
    required this.usersProcessed,
    required this.errors,
    required this.dryRun,
  });

  @override
  String toString() {
    final mode = dryRun ? '[DRY RUN] ' : '';
    return '''
${mode}Migration Result:
- Success: $success
- Users processed: $usersProcessed
- Bookings needing year: $bookingsUpdated
- Bookings already migrated: $bookingsAlreadyMigrated
- Errors: ${errors.length}
${errors.isNotEmpty ? 'Errors:\n${errors.join('\n')}' : ''}
''';
  }
}
