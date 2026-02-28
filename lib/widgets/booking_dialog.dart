import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../models/booking.dart';
import '../models/user.dart';
import '../pages/credits_page.dart';
import '../services/cloud_firestore.dart';
import '../services/email.dart';
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
      
      final creditSuccess = await CloudFirestore().decreaseCreditsAtomic(1, userId);
      
      if (!creditSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You are out of credits")),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      var uuid = const Uuid();
      final selectedDate = DateTime(
        DateTime.now().year,
        widget.month,
        widget.day,
      );
      
      Booking userBooking = Booking(
        id: uuid.v1(),
        bookingName: user.name,
        trainer: widget.trainer,
        price: widget.booking.price,
        time: widget.booking.time,
        date: "${widget.day}/${widget.month}/${selectedDate.year}",
      );

      final bookingSuccess = await CloudFirestore().bookSlotAtomic(
        booking: userBooking,
        userID: userId,
        month: widget.month,
        username: user.name,
      );

      if (!bookingSuccess) {
        CloudFirestore().incrementCredit(1, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("This slot was just booked. Please choose another time.",
                  style: GoogleFonts.plusJakartaSans()),
              backgroundColor: bbAccentAlt,
            ),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      EmailService().sendBookingConfirmationToMark(userBooking);
      EmailService().sendBookingConfirmationToUser(userBooking);

      if (mounted) {
        Navigator.pop(context, 'dialog');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Session confirmed.",
                style: GoogleFonts.plusJakartaSans()),
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
            Text(
              "Confirm your\nsession.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                color: bbText,
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow("Date",
                "${widget.day}/${widget.month}/${DateTime.now().year}"),
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
                  final hasCredits = snapshot.data!.credits > 0;
                  return Column(
                    children: [
                      // Primary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isProcessing || !hasCredits
                              ? null
                              : () => _handleBooking(snapshot.data!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bbAccent,
                            foregroundColor: Colors.white,
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
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  hasCredits
                                      ? "Use 1 Credit"
                                      : "No Credits Available",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Secondary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreditsPage(),
                                    ),
                                  );
                                },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: bbBorder, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Browse Plans",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: bbText,
                            ),
                          ),
                        ),
                      ),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: bbTextSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
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
