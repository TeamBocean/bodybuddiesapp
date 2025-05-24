import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MySessionsPage extends StatefulWidget {
  const MySessionsPage({Key? key}) : super(key: key);

  @override
  State<MySessionsPage> createState() => _MySessionsPageState();
}

class _MySessionsPageState extends State<MySessionsPage> {
  bool _showCompletedSessions = false;

  @override
  void initState() {
    super.initState();
    // Add a test dummy booking
    _addTestBooking();
  }

  void _addTestBooking() async {
    // Create a test booking that's already completed (yesterday)
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final testBooking = Booking(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      bookingName: 'Test User',
      trainer: 'Mark',
      price: 1,
      date: '${yesterday.day}/${yesterday.month}/${yesterday.year}',
      time: '10:00',
    );

    // // Add the test booking to Firestore
    // CloudFirestore().addUserBooking(
    //   testBooking,
    //   FirebaseAuth.instance.currentUser!.uid,
    //   yesterday.month,
    //   'Test User',
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        backgroundColor: background,
      ),
      body: StreamBuilder<UserModel?>(
        stream: CloudFirestore()
            .streamUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          // Filter bookings for current month
          final thisMonthBookings = user.bookings.where((booking) {
            final parts = booking.date.split('/');
            final bookingMonth = int.parse(parts[1]);
            final bookingYear =
                parts.length == 3 ? int.parse(parts[2]) : currentYear;
            return bookingMonth == currentMonth && bookingYear == currentYear;
          }).toList();

          // Filter upcoming bookings
          final upcomingBookings = user.bookings.where((booking) {
            final bookingDateTime = _getBookingDateTime(booking);
            return bookingDateTime.isAfter(now);
          }).toList();

          // Filter completed bookings
          final completedBookings = user.bookings.where((booking) {
            final bookingDateTime = _getBookingDateTime(booking);
            return bookingDateTime.isBefore(now);
          }).toList();

          // Filter and sort all bookings
          final allBookings = user.bookings.where((booking) {
            final bookingDateTime = _getBookingDateTime(booking);
            return _showCompletedSessions || bookingDateTime.isAfter(now);
          }).toList()
            ..sort((a, b) {
              final aDateTime = _getBookingDateTime(a);
              final bDateTime = _getBookingDateTime(b);
              
              // If both are upcoming or both are completed
              if ((aDateTime.isAfter(now) && bDateTime.isAfter(now)) ||
                  (!aDateTime.isAfter(now) && !bDateTime.isAfter(now))) {
                // For upcoming: earliest first, for completed: most recent first
                return aDateTime.isAfter(now)
                    ? aDateTime.compareTo(bDateTime)
                    : bDateTime.compareTo(aDateTime);
              }
              
              // If one is upcoming and one is completed, upcoming comes first
              return aDateTime.isAfter(now) ? -1 : 1;
            });

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Section
                  Container(
                    padding: EdgeInsets.all(Dimensions.width15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          context,
                          "Upcoming Sessions",
                          upcomingBookings.length.toString(),
                          Icons.calendar_today,
                        ),
                        SizedBox(height: Dimensions.height15),
                        _buildStatRow(
                          context,
                          "Sessions This Month",
                          thisMonthBookings.length.toString(),
                          Icons.fitness_center,
                        ),
                        SizedBox(height: Dimensions.height15),
                        _buildStatRow(
                          context,
                          "Completed Sessions",
                          completedBookings.length.toString(),
                          Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),

                  // All Bookings Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MediumTextWidget(
                        text: "All Sessions",
                        fontSize: Dimensions.fontSize22,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCompletedSessions = !_showCompletedSessions;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _showCompletedSessions
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).colorScheme.primary,
                                size: Dimensions.iconSize20,
                              ),
                              SizedBox(width: Dimensions.width5),
                              MediumTextWidget(
                                text: _showCompletedSessions
                                    ? "Hide Completed"
                                    : "Show Completed",
                                fontSize: Dimensions.fontSize14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  ...allBookings
                      .map((booking) => Padding(
                            padding:
                                EdgeInsets.only(bottom: Dimensions.height10),
                            child: BookingWidget(
                              isBooked: true,
                              slots: const [],
                              booking: booking,
                              isAdmin: false,
                              month: 0,
                            ),
                          ))
                      .toList(),
                  SizedBox(height: Dimensions.height10 * 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String title, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: Dimensions.iconSize20,
            ),
            SizedBox(width: Dimensions.width10),
            MediumTextWidget(
              text: title,
              fontSize: Dimensions.fontSize16,
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height5,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: MediumTextWidget(
            text: value,
            fontSize: Dimensions.fontSize16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  DateTime _getBookingDateTime(Booking booking) {
    List<String> dateParts = booking.date.split('/');
    int bookingDay = int.parse(dateParts[0]);
    int bookingMonth = int.parse(dateParts[1]);
    int bookingYear =
        dateParts.length == 3 ? int.parse(dateParts[2]) : DateTime.now().year;

    List<String> timeParts = booking.time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return DateTime(bookingYear, bookingMonth, bookingDay, hour, minute);
  }
}
