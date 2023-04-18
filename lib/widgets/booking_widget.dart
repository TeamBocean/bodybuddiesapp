import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/bookings.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/booking_dialog.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/email.dart';

class BookingWidget extends StatefulWidget {
  Booking booking;
  bool isBooked;

  BookingWidget({super.key, required this.booking, required this.isBooked});

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
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10 / 2),
              child: Opacity(
                opacity: isAlreadyBooked(widget.booking,
                    snapshot.data!.list) ? 0.5 : 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: Dimensions.height10 * 12,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.width15)),
                    color: darkGrey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.width15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MediumTextWidget(
                                text: widget.booking.time,
                                fontSize: Dimensions.fontSize16,
                              ),
                              MediumTextWidget(
                                text: widget.booking.bookingName,
                                fontSize: Dimensions.fontSize16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: Dimensions.width15 * 4.5,
                                    height: Dimensions.height10 * 2,
                                    child: Card(
                                      margin: EdgeInsets.all(0),
                                      elevation: 0,
                                      color: darkGreen,
                                      child: Center(
                                        child: MediumTextWidget(
                                          text: "Upcoming",
                                          color: Colors.black,
                                          fontSize: Dimensions.fontSize10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MediumTextWidget(
                                text: widget.booking.date,
                                fontSize: Dimensions.fontSize16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: Dimensions.width15 * 7,
                                    height: Dimensions.height10 * 2.5,
                                    child: ElevatedButton(
                                      onPressed: () => widget.isBooked
                                          ? print("Booked")
                                          : isAlreadyBooked(widget.booking,
                                                  snapshot.data!.list)
                                              ? print("Not available")
                                              : bookingDialog(
                                                  context, widget.booking),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.grey),
                                      child: Center(
                                        child: MediumTextWidget(
                                          text: widget.isBooked
                                              ? "Booked"
                                              : isAlreadyBooked(widget.booking,
                                                      snapshot.data!.list)
                                                  ? "Unavailable"
                                                  : "Book",
                                          color: Colors.black,
                                          fontSize: Dimensions.fontSize12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Dimensions.width10,
                                  ),
                                  Visibility(
                                    visible: widget.isBooked,
                                    child: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                    contentPadding: EdgeInsets.zero,
                                                    content: Container(
                                                      width: MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      height:
                                                          Dimensions.height10 * 12,
                                                      color: darkGrey,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: Dimensions
                                                                        .height10),
                                                            child: Center(
                                                              child: Text(
                                                                "Are you sure you want to cancel your booking?",
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                    fontSize: Dimensions
                                                                        .fontSize16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              IconButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        'dialog');
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color:
                                                                        Colors.red,
                                                                  )),
                                                              IconButton(
                                                                  onPressed: () {
                                                                    CloudFirestore().removeUserBooking(
                                                                        widget
                                                                            .booking,
                                                                        FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid);
                                                                    Navigator.pop(
                                                                        context,
                                                                        'dialog');
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .green,
                                                                  ))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        )),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Text("Loading");
          }
        });
  }

  bool isAlreadyBooked(Booking booking, Map bookings) {
    List<dynamic>? bookedTimes = bookings
            .containsKey(booking.date.split('/').last)
        ? bookings[booking.date.split('/').last][booking.date.split('/').first]
        : [];
    return bookedTimes != null ? bookedTimes.contains(booking.time) : false;
  }
}
