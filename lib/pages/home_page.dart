import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/medium_text_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    print("${FirebaseAuth.instance.currentUser}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: CloudFirestore()
            .streamUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
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
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade400,
                              radius: Dimensions.width27,
                              child: MediumTextWidget(
                                text: FirebaseAuth
                                    .instance.currentUser!.displayName!
                                    .substring(0, 1),
                                color: Colors.black,
                              ),
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
                                    top: Dimensions.height35 * 3.2),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: snapshot.data!.bookings
                                      .map((booking) => BookingWidget(
                                            booking: booking,
                                          ))
                                      .toList(),
                                ),
                              )
                            : noBookings()
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
                MediumTextWidget(
                    text:
                        "Hi, ${FirebaseAuth.instance.currentUser!.displayName!.split(' ').first}"),
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

  String getTodaysDate() {
    return "${months[DateTime.now().month - 1]}, ${DateTime.now().day}";
  }

  Widget noBookings() {
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
          text: "You Have No Bookings",
          fontSize: Dimensions.fontSize20,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        MediumTextWidget(
          text: "Click On Book Now To Get Started",
          fontSize: Dimensions.fontSize12,
          color: Colors.grey,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        SizedBox(
          width: Dimensions.width10 * 20,
          child: ElevatedButton(
            onPressed: () {
              CloudFirestore().addBooking(
                  Booking(
                      bookingName: "Home Workout Session",
                      price: 2,
                      time: "Time",
                      date: "Date"),
                  FirebaseAuth.instance.currentUser!.uid);
            },
            style: ElevatedButton.styleFrom(
                primary: darkGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.width10))),
            child: MediumTextWidget(
              text: "Book Now",
            ),
          ),
        )
      ],
    );
  }
}
