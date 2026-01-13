import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/bookings.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/booking_dialog.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingWidget extends StatefulWidget {
  final Booking booking;
  final bool isBooked;
  final bool isAdmin;
  final int month;
  final int day;
  final List<Widget> slots;
  final String trainer;

  const BookingWidget({
    Key? key,
    required this.booking,
    required this.isBooked,
    required this.month,
    required this.slots,
    required this.isAdmin,
    this.day = 0,
    this.trainer = "",
  }) : super(key: key);

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  Bookings? _previousData;

  @override
  Widget build(BuildContext context) {
    // Use booking's year for the stream
    return StreamBuilder<Bookings>(
      stream: CloudFirestore().streamBookedDates("", year: widget.booking.year),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _previousData = snapshot.data;
          final isBooked = isAlreadyBooked(widget.booking, snapshot.data!.list);
          // Use centralized Booking model methods
          final isPast = widget.booking.isPast;
          final isDisabled = (isBooked && !widget.isBooked) || isPast;

          return _buildBookingCard(context, isDisabled, snapshot.data!.list);
        } else if (_previousData != null) {
          // Use previous data while loading
          final isBooked = isAlreadyBooked(widget.booking, _previousData!.list);
          final isPast = widget.booking.isPast;
          final isDisabled = (isBooked && !widget.isBooked) || isPast;

          return _buildBookingCard(context, isDisabled, _previousData!.list);
        } else {
          // Show a skeleton loading state for the first load
          return _buildSkeletonCard(context);
        }
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, bool isDisabled, Map bookings) {
    return AbsorbPointer(
      absorbing: isDisabled,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 0, vertical: Dimensions.height10 / 2),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 165,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.width15),
              ),
              color: darkGrey,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Stack(
                  children: [
                    _buildBookingInfo(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildBookingActions(context, bookings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 0, vertical: Dimensions.height10 / 2),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 165,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.width15),
          ),
          color: darkGrey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Stack(
              children: [
                _buildBookingInfo(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    // Use centralized Booking model methods
    final isPast = widget.booking.isPast;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            MediumTextWidget(
              text: widget.booking.time,
              fontSize: Dimensions.fontSize16,
            ),
            Visibility(
              visible: widget.isBooked,
              child: MediumTextWidget(
                text: " | ${widget.booking.trainer}",
                fontSize: Dimensions.fontSize16,
              ),
            ),
          ],
        ),
        SizedBox(
          width: Dimensions.width20 * 9.5,
          child: MediumTextWidget(
            text: widget.booking.bookingName,
            fontSize: Dimensions.fontSize16,
          ),
        ),
        SizedBox(
          width: Dimensions.width15 * 5,
          height: Dimensions.height10 * 2.5,
          child: Card(
            margin: const EdgeInsets.all(0),
            elevation: 0,
            color: darkGreen,
            child: Center(
              child: MediumTextWidget(
                text: isPast ? "Done" : "Upcoming",
                color: Colors.black,
                fontSize: Dimensions.fontSize12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column _buildBookingActions(BuildContext context, Map bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MediumTextWidget(
          text: _formatDate(widget.booking),
          fontSize: Dimensions.fontSize15,
        ),
        SizedBox(
          height: Dimensions.height10 * 3,
          width: Dimensions.width10 * 12,
          child: ElevatedButton(
            onPressed: () => _handleBookingButtonPress(context, bookings),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Center(
              child: MediumTextWidget(
                text: _getBookingButtonText(bookings),
                color: Colors.black,
                fontSize: Dimensions.fontSize12,
              ),
            ),
          ),
        ),
        if (widget.isBooked)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showCancelBookingDialog(context),
            icon: const Icon(Icons.delete, color: Colors.grey),
          ),
      ],
    );
  }

  void _handleBookingButtonPress(BuildContext context, Map bookings) {
    if (widget.isBooked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Booked")));
    } else if (isAlreadyBooked(widget.booking, bookings)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Not Available")));
    } else {
      // Use booking's day and month from centralized methods
      bookingDialog(
        context,
        widget.booking,
        widget.booking.month,
        widget.booking.day,
        widget.trainer.isNotEmpty ? widget.trainer : widget.booking.trainer,
      );
    }
  }

  String _getBookingButtonText(Map bookings) {
    if (widget.isBooked) {
      return "Booked";
    } else if (isAlreadyBooked(widget.booking, bookings)) {
      return "Unavailable";
    } else {
      return "Book";
    }
  }

  void _showCancelBookingDialog(BuildContext context) {
    // Check if within 24 hours
    final isWithin24Hours = widget.booking.isWithin24Hours;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(Dimensions.height15),
          color: darkGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: Dimensions.height10),
                child: Center(
                  child: Text(
                    "Are you sure you want to cancel your booking?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Dimensions.fontSize16, color: Colors.white),
                  ),
                ),
              ),
              if (isWithin24Hours) ...[
                SizedBox(height: Dimensions.height10),
                Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: Text(
                          "Cancelling within 24 hours of the session will NOT refund your credit.",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: Dimensions.fontSize12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: Dimensions.height15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, 'dialog'),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      CloudFirestore().removeUserBooking(
                        widget.booking,
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                      Navigator.pop(context, 'dialog');
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking Successfully Deleted"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if booking is already booked using centralized Booking properties
  bool isAlreadyBooked(Booking booking, Map bookings) {
    // Use centralized properties from Booking model
    String month = booking.month.toString();
    String day = booking.day.toString();
    
    List<dynamic>? bookedTimes = bookings[month]?[day];
    return bookedTimes != null && bookedTimes.contains(booking.time);
  }

  /// Format date for display using centralized Booking properties
  String _formatDate(Booking booking) {
    int day = booking.day;
    int month = booking.month;
    String suffix = _getDaySuffix(day);
    return '$day$suffix ${_getMonthName(month)}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    if (month < 1 || month > 12) {
      throw RangeError("Invalid month index: $month");
    }
    return monthNames[month - 1];
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
