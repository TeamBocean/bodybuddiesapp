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
    return MigrationResult(
      success: false,
      bookingsUpdated: 0,
      bookingsAlreadyMigrated: 0,
      usersProcessed: 0,
      errors: const [
        'Client-side migration is disabled. Run the Admin SDK backfill.',
      ],
      dryRun: false,
    );
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

  Future<void> _migrateUserBookings(DocumentSnapshot userDoc,
      {required bool dryRun}) async {
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

  /// Legacy yearless records came from the 2025 dataset.
  int _inferYear(List<String> _) => 2025;
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
