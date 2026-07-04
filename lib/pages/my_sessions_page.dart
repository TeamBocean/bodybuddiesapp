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
      backgroundColor: bbBackground,
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: CloudFirestore()
              .streamUserData(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: bbAccent,
                  strokeWidth: 1.5,
                ),
              );
            }

            final user = snapshot.data!;
            final now = DateTime.now();
            final currentMonth = now.month;
            final currentYear = now.year;

            final thisMonthBookings = user.bookings.where((booking) {
              return booking.month == currentMonth &&
                  booking.year == currentYear;
            }).toList();

            final upcomingBookings = user.bookings.where((booking) {
              return booking.isUpcoming;
            }).toList();

            final completedBookings = user.bookings.where((booking) {
              return booking.isPast;
            }).toList();

            final allBookings = user.bookings.where((booking) {
              return _showCompletedSessions || booking.isUpcoming;
            }).toList()
              ..sort((a, b) {
                final aDateTime = a.getDateTime();
                final bDateTime = b.getDateTime();

                if ((a.isUpcoming && b.isUpcoming) || (a.isPast && b.isPast)) {
                  return a.isUpcoming
                      ? aDateTime.compareTo(bDateTime)
                      : bDateTime.compareTo(aDateTime);
                }
                return a.isUpcoming ? -1 : 1;
              });

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Header ───────────────────────────────────────────
                    Text(
                      "SESSIONS",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: bbTextMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Stats — floating text, no boxes ──────────────────
                    Row(
                      children: [
                        _buildStat(
                            upcomingBookings.length.toString(), "UPCOMING"),
                        const SizedBox(width: 24),
                        _buildStat(
                            thisMonthBookings.length.toString(), "THIS MONTH"),
                        const SizedBox(width: 24),
                        _buildStat(completedBookings.length.toString(), "DONE"),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Toggle ────────────────────────────────────────────
                    Row(
                      children: [
                        Text(
                          _showCompletedSessions ? "ALL SESSIONS" : "UPCOMING",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: bbTextSecondary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                              height: 0.25, color: bbBorder.withOpacity(0.5)),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCompletedSessions = !_showCompletedSessions;
                            });
                          },
                          child: Text(
                            _showCompletedSessions
                                ? "HIDE COMPLETED"
                                : "SHOW COMPLETED",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: bbAccent,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              decoration: TextDecoration.underline,
                              decorationColor: bbAccent.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Session List ──────────────────────────────────────
                    if (allBookings.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: Dimensions.height20 * 3),
                        child: Center(
                          child: Text(
                            "NO SESSIONS YET.",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: bbTextMuted,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      )
                    else
                      ...allBookings
                          .map((booking) => BookingWidget(
                                isBooked: true,
                                slots: const [],
                                booking: booking,
                                isAdmin: false,
                                month: 0,
                              ))
                          .toList(),
                    SizedBox(height: Dimensions.height10 * 6),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Floating stat (number + label, no box) ──────────────────────────────
  Widget _buildStat(String value, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            color: bbText,
            fontWeight: FontWeight.w300,
            height: 1.0,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: bbTextMuted,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
