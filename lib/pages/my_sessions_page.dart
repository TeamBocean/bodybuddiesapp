import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        backgroundColor: bbBlack,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.anton(
                fontSize: 22,
                color: const Color(0xFF3A3A3A),
                letterSpacing: 2),
            children: const [
              TextSpan(text: "MY "),
              TextSpan(
                text: "SESSIONS.",
                style: TextStyle(color: bbAccent),
              ),
            ],
          ),
        ),
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
                  // ── Editorial Stats Row ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          upcomingBookings.length.toString(),
                          "UPCOMING",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          thisMonthBookings.length.toString(),
                          "THIS MONTH",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          completedBookings.length.toString(),
                          "DONE",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),

                  // ── Editorial Section Header ─────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "ALL SESSIONS",
                        style: GoogleFonts.anton(
                          fontSize: 18,
                          color: bbWhite,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Container(height: 0.5, color: bbBorder)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCompletedSessions = !_showCompletedSessions;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: bbCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: bbBorder, width: 0.5),
                          ),
                          child: Text(
                            _showCompletedSessions ? "HIDE DONE" : "SHOW DONE",
                            style: GoogleFonts.robotoMono(
                              fontSize: 9,
                              color: bbGrey,
                              letterSpacing: 1,
                            ),
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
                            Text(
                              "NO\nSESSIONS.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.anton(
                                fontSize: 36,
                                color: bbBorder,
                                height: 0.95,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              "Book your first session.",
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                color: bbGrey,
                                letterSpacing: 1,
                              ),
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

  // ─── Editorial Stat Card ────────────────────────────────────────────────
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: bbCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bbBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.anton(
              fontSize: 30,
              color: bbAccent,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.robotoMono(
              fontSize: 9,
              color: bbGrey,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
