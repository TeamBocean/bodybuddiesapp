import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/user.dart';
import '../services/cloud_firestore.dart';
import '../utils/dimensions.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<Widget> dates = [];
  String _day = DateTime.now().day.toString();
  DateTime currentDay = DateTime.now();
  final _currentDate = DateTime.now();
  DateTime startTimeOne = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 15, 0);
  // DateTime startTimeTwo = DateTime(
  //     DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 0, 0);
  // DateTime endTime = DateTime(
  //     DateTime.now().year, DateTime.now().month, DateTime.now().day, 21, 0, 0);
  Duration step = Duration(minutes: 45);
  List<Widget> slots = [];

  @override
  void initState() {
    initDates(context);
    super.initState();
  }

  void initDates(BuildContext context) {
    dates.clear();
    for (int i = 0; i < 30; i++) {
      final date = _currentDate.add(Duration(days: i));
      setState(() {
        dates.add(dateWidget(date, daysOfWeek[date.weekday - 1].substring(0, 3),
            date.day.toString() == _day));
      });
    }

    setState(() {
      slots.clear();

      DateTime startTime = currentDay.weekday % 2 == 0
          ? DateTime(
              currentDay.year, currentDay.month, currentDay.day, 6, 30, 0)
          : DateTime(
              currentDay.year, currentDay.month, currentDay.day, 14, 15, 0);
      DateTime endTime = DateTime(currentDay.year, currentDay.month, currentDay.day, 20, 30, 0);
      if (currentDay.weekday != 6 && currentDay.weekday != 7) {
        DateFormat df = new DateFormat('HH:mm');

        while (startTime.isBefore(endTime)) {
          DateTime timeIncrement = startTime.add(step);
          setState(() {
            slots.add(BookingWidget(
                isBooked: false,
                booking: Booking(
                  bookingName: "Test",
                  price: 1,
                  date: currentDay.day.toString() +
                      "/" +
                      currentDay.month.toString(),
                  time: df.format(timeIncrement),
                )));
          });

          startTime = timeIncrement;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initDates(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: StreamBuilder<UserModel>(
            stream: CloudFirestore()
                .streamUserData(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: MediumTextWidget(
                            text:
                                "${months[DateTime.now().month - 1]} ${DateTime.now().year}",
                            fontSize: Dimensions.fontSize18,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: Dimensions.width15),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => showCalendarDialog(),
                              splashRadius: 0.1,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 22, maxWidth: 22),
                              icon: Icon(Icons.calendar_month),
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimensions.width15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dates.map((date) => date).toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Dimensions.width20),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: MediumTextWidget(text: "Available Sessions")),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          (Dimensions.height50 * 4 + Dimensions.height10 * 8),
                      child: SingleChildScrollView(
                        child: Column(
                          children: slots
                              .map((booking) => AbsorbPointer(
                                    absorbing: snapshot.data!.bookings
                                                .firstWhereOrNull((element) =>
                                                    formatBookingDate(element)
                                                        .day ==
                                                    currentDay.day) !=
                                            null
                                        ? true
                                        : false,
                                    child: Opacity(
                                        opacity: snapshot.data!.bookings
                                                    .firstWhereOrNull(
                                                        (element) =>
                                                            formatBookingDate(
                                                                    element)
                                                                .day ==
                                                            currentDay.day) !=
                                                null
                                            ? 0.5
                                            : 1,
                                        child: booking),
                                  ))
                              .toList(),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return Text("Loading");
              }
            }),
      ),
    );
  }

  DateTime formatBookingDate(Booking booking) {
    return DateTime(
      DateTime.now().year,
      int.parse(booking.date.split('/')[0]),
      int.parse(booking.date.split('/')[0]),
    );
  }

  Widget dateWidget(DateTime dateTime, String weekDay, bool isCurrent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 / 2.5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _day = dateTime.day.toString();
            currentDay = dateTime;
            initDates(context);
          });
        },
        child: SizedBox(
          width: Dimensions.width10 * 4,
          height: Dimensions.height10 * 5.5,
          child: Card(
            color: isCurrent ? darkGreen : darkGrey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.width10 / 2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MediumTextWidget(
                  text: dateTime.day.toString(),
                  fontSize: Dimensions.fontSize10,
                ),
                MediumTextWidget(
                  text: weekDay,
                  fontSize: Dimensions.fontSize10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showCalendarDialog() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year, 12, 30));

    if (pickedDate != null) {
      setState(() {
        _day = pickedDate.day.toString();
        currentDay = pickedDate;
        initDates(context);
      });
    }
  }
}
