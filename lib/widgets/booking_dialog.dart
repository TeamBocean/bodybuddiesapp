import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/booking.dart';
import '../models/user.dart';
import '../pages/credits_page.dart';
import '../services/cloud_firestore.dart';
import '../services/email.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'medium_text_widget.dart';

/// Shows the booking confirmation dialog.
/// Converted to use a StatefulWidget internally to prevent double-booking.
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
    if (_isProcessing) return; // Prevent double-tap

    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      // Use atomic credit deduction to prevent race conditions
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

      // Create booking with year included
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

      // Use atomic booking to prevent double-booking
      final bookingSuccess = await CloudFirestore().bookSlotAtomic(
        booking: userBooking,
        userID: userId,
        month: widget.month,
        username: user.name,
      );

      if (!bookingSuccess) {
        // Slot was taken by someone else - refund the credit
        CloudFirestore().incrementCredit(1, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This slot was just booked. Please choose another time."),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      // Send confirmation emails after successful booking
      EmailService().sendBookingConfirmationToMark(userBooking);
      EmailService().sendBookingConfirmationToUser(userBooking);

      if (mounted) {
        Navigator.pop(context, 'dialog');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking confirmed!"),
            backgroundColor: Colors.green,
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
    return AlertDialog(
      backgroundColor: darkGrey,
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15, vertical: Dimensions.width15),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: MediumTextWidget(
                  text: "Book this session",
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MediumTextWidget(
                      text: "Reservation Details",
                      fontSize: Dimensions.fontSize14,
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MediumTextWidget(
                          text: "Date",
                          fontSize: Dimensions.fontSize14,
                        ),
                        MediumTextWidget(
                          text: "${widget.day}/${widget.month}/${DateTime.now().year}",
                          fontSize: Dimensions.fontSize14,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MediumTextWidget(
                          text: "Time",
                          fontSize: Dimensions.fontSize14,
                        ),
                        MediumTextWidget(
                          text: widget.booking.time,
                          fontSize: Dimensions.fontSize14,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MediumTextWidget(
                          text: "Duration",
                          fontSize: Dimensions.fontSize14,
                        ),
                        MediumTextWidget(
                          text: "45 Mins",
                          fontSize: Dimensions.fontSize14,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MediumTextWidget(
                          text: "Number of People",
                          fontSize: Dimensions.fontSize14,
                        ),
                        MediumTextWidget(
                          text: "-  1  +",
                          fontSize: Dimensions.fontSize14,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MediumTextWidget(
                          text: "Trainer",
                          fontSize: Dimensions.fontSize14,
                        ),
                        MediumTextWidget(
                          text: widget.trainer,
                          fontSize: Dimensions.fontSize14,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height30,
                    ),
                    StreamBuilder<UserModel>(
                        stream: CloudFirestore().streamUserData(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final hasCredits = snapshot.data!.credits > 0;
                            return Center(
                              child: SizedBox(
                                width: Dimensions.width10 * 20,
                                height: Dimensions.height50,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _isProcessing
                                            ? darkGrey
                                            : darkGreen,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    Dimensions.width15))),
                                    onPressed: _isProcessing || !hasCredits
                                        ? null
                                        : () => _handleBooking(snapshot.data!),
                                    child: _isProcessing
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : MediumTextWidget(
                                            text: hasCredits
                                                ? "Use 1 Credit"
                                                : "No Credits",
                                            fontSize: Dimensions.fontSize12,
                                            color: hasCredits
                                                ? Colors.black
                                                : Colors.white54,
                                          )),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text("Loading.."),
                            );
                          }
                        }),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Center(
                        child: MediumTextWidget(
                      text: "OR",
                      fontSize: Dimensions.fontSize16,
                    )),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Center(
                      child: SizedBox(
                        width: Dimensions.width10 * 20,
                        height: Dimensions.height50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: darkGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.width15))),
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CreditsPage()));
                                  },
                            child: MediumTextWidget(
                              text: "Buy Credits",
                              fontSize: Dimensions.fontSize12,
                              color: Colors.black,
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
