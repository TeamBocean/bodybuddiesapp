import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySessionsPage extends StatefulWidget {
  const MySessionsPage({Key? key}) : super(key: key);

  @override
  State<MySessionsPage> createState() => _MySessionsPageState();
}

class _MySessionsPageState extends State<MySessionsPage> {
  bool _showCompletedSessions = false;

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

          // Filter bookings for current month using centralized methods
          final thisMonthBookings = user.bookings.where((booking) {
            return booking.month == currentMonth && booking.year == currentYear;
          }).toList();

          // Filter upcoming bookings using centralized isUpcoming property
          final upcomingBookings = user.bookings.where((booking) {
            return booking.isUpcoming;
          }).toList();

          // Filter completed bookings using centralized isPast property
          final completedBookings = user.bookings.where((booking) {
            return booking.isPast;
          }).toList();

          // Filter and sort all bookings
          final allBookings = user.bookings.where((booking) {
            return _showCompletedSessions || booking.isUpcoming;
          }).toList()
            ..sort((a, b) {
              final aDateTime = a.getDateTime();
              final bDateTime = b.getDateTime();
              
              // If both are upcoming or both are completed
              if ((a.isUpcoming && b.isUpcoming) || (a.isPast && b.isPast)) {
                // For upcoming: earliest first, for completed: most recent first
                return a.isUpcoming
                    ? aDateTime.compareTo(bDateTime)
                    : bDateTime.compareTo(aDateTime);
              }
              
              // If one is upcoming and one is completed, upcoming comes first
              return a.isUpcoming ? -1 : 1;
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
                  
                  if (allBookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: Dimensions.height20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            SizedBox(height: Dimensions.height10),
                            MediumTextWidget(
                              text: "No sessions to display",
                              fontSize: Dimensions.fontSize16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
}
