import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../models/booking.dart';
import '../models/user.dart';
import '../pages/credits_page.dart';
import '../services/cloud_firestore.dart';
import '../utils/colors.dart';

/// Shows the booking confirmation dialog.
void bookingDialog(
    BuildContext context, Booking booking, int month, int day, String trainer) {
  showDialog(
    context: context,
    builder: (_) => _BookingDialogContent(
      booking: booking,
      month: month,
      day: day,
      trainer: trainer,
    ),
  );
}

class _BookingDialogContent extends StatefulWidget {
  final Booking booking;
  final int month;
  final int day;
  final String trainer;

  const _BookingDialogContent({
    required this.booking,
    required this.month,
    required this.day,
    required this.trainer,
  });

  @override
  State<_BookingDialogContent> createState() => _BookingDialogContentState();
}

class _BookingDialogContentState extends State<_BookingDialogContent> {
  bool _isProcessing = false;

  Future<void> _handleBooking(UserModel user) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Use the selected booking's year (not "now") so bookings made near
      // New Year are stored against the correct year.
      var uuid = const Uuid();
      final selectedDate = DateTime(
        widget.booking.year,
        widget.month,
        widget.day,
      );

      Booking userBooking = Booking(
        id: uuid.v1(),
        bookingName: user.name,
        trainer: widget.trainer,
        trainerId: widget.booking.trainerId,
        price: widget.booking.price,
        time: widget.booking.time,
        date: "${widget.day}/${widget.month}/${selectedDate.year}",
      );

      final bookingResult = await CloudFirestore().bookSlotAtomic(
        booking: userBooking,
        userID: userId,
        month: widget.month,
        username: user.name,
        userEmail: user.email,
      );

      if (bookingResult != BookingResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  bookingResult == BookingResult.noCredits
                      ? "You are out of credits."
                      : bookingResult == BookingResult.conflict
                          ? "This slot was just booked. Please choose another time."
                          : "We couldn't complete the booking. Please try again.",
                  style: GoogleFonts.inter(color: bbOnAccent)),
              backgroundColor: bbAccentAlt,
            ),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      if (mounted) {
        Navigator.pop(context, 'dialog');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Session confirmed.",
              style: GoogleFonts.inter(color: bbOnAccent),
            ),
            backgroundColor: bbAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error booking: $e")),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _openPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreditsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bbSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Semantics(
              header: true,
              child: Text(
                "Confirm your\nsession.",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  color: bbText,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow(
                "Date", "${widget.day}/${widget.month}/${widget.booking.year}"),
            _buildDivider(),
            _buildDetailRow("Time", widget.booking.time),
            _buildDivider(),
            _buildDetailRow("Duration", "45 minutes"),
            _buildDivider(),
            _buildDetailRow("Trainer", widget.trainer),
            const SizedBox(height: 28),

            // Action buttons
            StreamBuilder<UserModel>(
              stream: CloudFirestore()
                  .streamUserData(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final credits = snapshot.data!.credits;
                  final hasCredits = credits > 0;
                  return Column(
                    children: [
                      // Current credit balance
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: bbCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Credit balance",
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: bbTextSecondary),
                            ),
                            Text(
                              "$credits ${credits == 1 ? 'credit' : 'credits'}",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: hasCredits ? bbAccent : bbAccentAlt,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (hasCredits) ...[
                        // Primary CTA — confirm the booking
                        Semantics(
                          button: true,
                          label: "Confirm booking for 1 credit",
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _handleBooking(snapshot.data!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bbAccent,
                                foregroundColor: bbOnAccent,
                                disabledBackgroundColor: bbCard,
                                disabledForegroundColor: bbTextMuted,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: bbOnAccent,
                                      ),
                                    )
                                  : Text(
                                      "Confirm booking · 1 credit",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Secondary CTA — browse plans
                        Semantics(
                          button: true,
                          label: "Browse credit plans",
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : _openPlans,
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: bbBorder, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Browse Plans",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: bbText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Out of credits — Browse Plans becomes the primary CTA
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            "You're out of credits. Grab a plan to book this session.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: bbTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: "Browse credit plans",
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _openPlans,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bbAccent,
                                foregroundColor: bbOnAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Browse Plans",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: bbAccent,
                      strokeWidth: 1.5,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: bbTextSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: bbText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: bbBorder, height: 1, thickness: 0.5);
  }
}
