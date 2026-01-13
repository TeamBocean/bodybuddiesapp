import 'package:flutter/material.dart';
import 'package:bodybuddiesapp/services/booking_migration.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';

/// Page for running the booking migration to add years to legacy dates
class BookingMigrationPage extends StatefulWidget {
  const BookingMigrationPage({Key? key}) : super(key: key);

  @override
  State<BookingMigrationPage> createState() => _BookingMigrationPageState();
}

class _BookingMigrationPageState extends State<BookingMigrationPage> {
  final BookingMigrationService _migrationService = BookingMigrationService();
  
  bool _isRunning = false;
  MigrationResult? _lastResult;
  String _status = 'Ready to run migration';

  Future<void> _runDryRun() async {
    setState(() {
      _isRunning = true;
      _status = 'Running dry run...';
    });

    try {
      final result = await _migrationService.dryRun();
      setState(() {
        _lastResult = result;
        _status = 'Dry run complete';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _runMigration() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkGrey,
        title: const Text(
          'Confirm Migration',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently update all booking dates in the database. '
          'Make sure you have run a dry run first and reviewed the results.\n\n'
          'Are you sure you want to proceed?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Run Migration'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRunning = true;
      _status = 'Running migration...';
    });

    try {
      final result = await _migrationService.migrate();
      setState(() {
        _lastResult = result;
        _status = result.success ? 'Migration complete!' : 'Migration completed with errors';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Migration'),
        backgroundColor: background,
      ),
      body: Container(
        color: background,
        padding: EdgeInsets.all(Dimensions.width15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: EdgeInsets.all(Dimensions.width15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: Dimensions.iconSize20),
                      SizedBox(width: Dimensions.width10),
                      MediumTextWidget(
                        text: 'About This Migration',
                        fontSize: Dimensions.fontSize16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  const Text(
                    'This migration fixes legacy bookings that were stored without a year '
                    '(e.g., "7/1" instead of "7/1/2025"). The migration will:\n\n'
                    '• Scan all user booking records\n'
                    '• Add the year 2025 to bookings without a year\n'
                    '• Leave bookings with years unchanged',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: Dimensions.height20),
            
            // Status Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Dimensions.width15),
              decoration: BoxDecoration(
                color: darkGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: 'Status',
                    fontSize: Dimensions.fontSize16,
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    children: [
                      if (_isRunning)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: darkGreen,
                          ),
                        )
                      else
                        Icon(
                          _lastResult?.success == true
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _lastResult?.success == true
                              ? Colors.green
                              : Colors.grey,
                          size: 16,
                        ),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: Text(
                          _status,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: Dimensions.height20),
            
            // Results Card (if available)
            if (_lastResult != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  color: darkGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MediumTextWidget(
                          text: _lastResult!.dryRun ? 'Dry Run Results' : 'Migration Results',
                          fontSize: Dimensions.fontSize16,
                        ),
                        if (_lastResult!.dryRun) ...[
                          SizedBox(width: Dimensions.width10),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DRY RUN',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: Dimensions.height15),
                    _buildResultRow('Users Processed', _lastResult!.usersProcessed.toString()),
                    _buildResultRow('Bookings Needing Update', _lastResult!.bookingsUpdated.toString()),
                    _buildResultRow('Already Migrated', _lastResult!.bookingsAlreadyMigrated.toString()),
                    _buildResultRow(
                      'Errors',
                      _lastResult!.errors.length.toString(),
                      isError: _lastResult!.errors.isNotEmpty,
                    ),
                    if (_lastResult!.errors.isNotEmpty) ...[
                      SizedBox(height: Dimensions.height10),
                      Container(
                        padding: EdgeInsets.all(Dimensions.width10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _lastResult!.errors
                              .map((e) => Text(
                                    e,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height20),
            ],
            
            const Spacer(),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _runDryRun,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGrey,
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: darkGreen),
                      ),
                    ),
                    child: MediumTextWidget(
                      text: 'Dry Run',
                      fontSize: Dimensions.fontSize14,
                      color: darkGreen,
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _runMigration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: MediumTextWidget(
                      text: 'Run Migration',
                      fontSize: Dimensions.fontSize14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: isError ? Colors.red : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
