import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/medium_text_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser!.email!
            .contains("markmcquaid54@gmail.com")
        ? adminView()
        : userView();
  }

  Widget adminView() {
    return StreamBuilder<List<Booking>>(
        stream: CloudFirestore()
            .streamAllBookings(currentDate.month, currentDate.day),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length > 0) {
              /// Sort bookings by date
              snapshot.data!.sort((a, b) => getBookingAsDateTime(a.time, a.date)
                      .isBefore(getBookingAsDateTime(b.time, b.date))
                  ? 0
                  : 1);

              /// Sort bookings by date
              snapshot.data!.sort((a, b) => isBookingComplete(a) ? 1 : 0);
            }
          }
          return Container(
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            userInformationHeader(),
                            FirebaseAuth.instance.currentUser!.photoURL != null
                                ? CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: Dimensions.width27,
                                    backgroundImage: NetworkImage(
                                      FirebaseAuth.instance.currentUser!
                                          .photoURL as String,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: Dimensions.width27,
                                    child: MediumTextWidget(
                                        text: "M", color: Colors.black),
                                  )
                          ],
                        ),
                        SizedBox(
                          height: Dimensions.height20 / 2,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: MediumTextWidget(
                              text: "Upcoming Sessions",
                              fontSize: Dimensions.fontSize22,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate =
                                        currentDate.subtract(Duration(days: 1));
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                )),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentDate = DateTime.now();
                                });
                              },
                              child: MediumTextWidget(
                                text:
                                    "${DateFormat.yMMMEd().format(currentDate)}",
                                fontSize: Dimensions.fontSize18,
                                color: darkGreen,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate =
                                        currentDate.add(Duration(days: 1));
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ],
                    ),
                    snapshot.hasData
                        ? snapshot.data!.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: Dimensions.height35 * 4.5,
                                    bottom: Dimensions.height10 * 6),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: snapshot.data!
                                        .map((booking) => BookingWidget(
                                              isBooked: true,
                                              slots: [],
                                              booking: booking,
                                              isAdmin: true,
                                              month: 0,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )
                            : noBookings("No Sessions Today", false)
                        : MediumTextWidget(text: "Loading...")
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget userView() {
    return StreamBuilder<UserModel>(
        stream: CloudFirestore()
            .streamUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.bookings.length > 0) {
              /// Sort bookings by date
              snapshot.data!.bookings.sort((a, b) => getBookingAsDateTime(a.time, a.date)
                  .isBefore(getBookingAsDateTime(b.time, b.date))
                  ? 0
                  : 1);

              /// Sort bookings by date
              snapshot.data!.bookings.sort((a, b) => isBookingComplete(a) ? 1 : 0);
            }
          }
          return Container(
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            userInformationHeader(),
                            FirebaseAuth.instance.currentUser!.photoURL != null
                                ? CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: Dimensions.width27,
                                    backgroundImage: NetworkImage(
                                      FirebaseAuth.instance.currentUser!
                                          .photoURL as String,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: Dimensions.width27,
                                    child: MediumTextWidget(
                                        text: snapshot.hasData
                                            ? snapshot.data!.name
                                                .substring(0, 1)
                                            : "",
                                        color: Colors.black),
                                  )
                          ],
                        ),
                        SizedBox(
                          height: Dimensions.height20,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: MediumTextWidget(
                              text: "Upcoming Bookings",
                              fontSize: Dimensions.fontSize22,
                            )),
                      ],
                    ),
                    snapshot.hasData
                        ? snapshot.data!.bookings.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: Dimensions.height35 * 3.2,
                                    bottom: Dimensions.height10 * 6),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: snapshot.data!.bookings
                                        .map((booking) => BookingWidget(
                                              isBooked: true,
                                              slots: [],
                                              booking: booking,
                                              isAdmin: false,
                                              month: 0,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )
                            : noBookings("You Have No Bookings", true)
                        : MediumTextWidget(text: "Loading...")
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget userInformationHeader() {
    return StreamBuilder<UserModel>(
        stream: CloudFirestore()
            .streamUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediumTextWidget(
                    text: getTodaysDate(),
                    color: darkGreen,
                    fontSize: Dimensions.fontSize14),
                MediumTextWidget(text: "Hi, ${snapshot.data!.name}"),
                MediumTextWidget(
                  text: "Remaining Credits: ${snapshot.data!.credits}",
                  fontSize: Dimensions.fontSize14,
                ),
              ],
            );
          } else {
            return MediumTextWidget(
              text: "Loading...",
              fontSize: Dimensions.fontSize14,
            );
          }
        });
  }

  String? getDisplayName() {
    return FirebaseAuth.instance.currentUser!.displayName != null
        ? FirebaseAuth.instance.currentUser!.displayName
        : "";
  }

  String getTodaysDate() {
    return "${months[DateTime.now().month - 1]}, ${DateTime.now().day}";
  }

  Widget noBookings(String message, bool showSubHeading) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            "${ASSETS}no_bookings.png",
            height: Dimensions.height10 * 15,
          ),
        ),
        MediumTextWidget(
          text: message,
          fontSize: Dimensions.fontSize20,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Visibility(
          visible: showSubHeading,
          child: MediumTextWidget(
            text: "Click On Bookings To Get Started",
            fontSize: Dimensions.fontSize12,
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  DateTime getBookingAsDateTime(String time, String date) {
    List<String> dateAsList = date.split("/");

    DateTime dateTime = DateTime.parse(
        "${DateTime.now().year}-0${dateAsList.last}-${dateAsList.first} $time:00");
    return dateTime;
  }

  bool isBookingComplete(Booking booking) {
    return DateTime.now()
        .isAfter(getBookingAsDateTime(booking.time, booking.date));
  }
}
