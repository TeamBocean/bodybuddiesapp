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

  const BookingWidget(
      {Key? key,
      required this.booking,
      required this.isBooked,
      required this.month,
      required this.slots,
      required this.isAdmin,
      this.day = 0,
      this.trainer = ""})
      : super(key: key);

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Bookings>(
      stream: CloudFirestore().streamBookedDates(""),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isBooked = isAlreadyBooked(widget.booking, snapshot.data!.list);
          final isPast =
              getBookingAsDateTime(widget.booking.time, widget.booking.date)
                  .isBefore(DateTime.now());
          final isDisabled = (isBooked && !widget.isBooked) || isPast;

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
                      padding: EdgeInsets.all(15),
                      child: Stack(
                        children: [
                          _buildBookingInfo(),
                          Align(
                              alignment: Alignment.centerRight,
                              child: _buildBookingActions(
                                  context, snapshot.data!.list)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Text("Loading");
        }
      },
    );
  }

  Widget _buildBookingInfo() {
    final isPast =
        getBookingAsDateTime(widget.booking.time, widget.booking.date)
            .isBefore(DateTime.now());
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
            margin: EdgeInsets.all(0),
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
          text: _formatDate(widget.booking.date),
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
            constraints: BoxConstraints(),
            onPressed: () => _showCancelBookingDialog(context),
            icon: Icon(Icons.delete, color: Colors.grey),
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
      bookingDialog(
          context, widget.booking, widget.month, widget.day, widget.trainer);
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width,
          height: Dimensions.height10 * 12,
          color: darkGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, 'dialog'),
                    icon: Icon(Icons.close, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      CloudFirestore().removeUserBooking(widget.booking,
                          FirebaseAuth.instance.currentUser!.uid);
                      Navigator.pop(context, 'dialog');
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Booking Successfully Deleted")));
                    },
                    icon: Icon(Icons.check, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime getBookingAsDateTime(String time, String date) {
    List<String> dateAsList = date.split("/");
    String day = dateAsList.first.padLeft(2, '0');
    String month = formatMonth(dateAsList[1]);
    String year = dateAsList.length > 2
        ? dateAsList.last
        : DateTime.now().year.toString(); // Use current year if missing
    DateTime dateTime = DateTime.parse(
      "$year-$month-$day $time:00",
    );
    return dateTime;
  }

  String formatMonth(String month) {
    return month.padLeft(2, '0');
  }

  bool isAlreadyBooked(Booking booking, Map bookings) {
    List<dynamic>? bookedTimes =
        bookings[booking.date.split('/').last]?[booking.date.split('/').first];
    return bookedTimes != null && bookedTimes.contains(booking.time);
  }

  String _formatDate(String date) {
    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts.first);
    int month = int.parse(dateParts[1]);
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
