import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/medium_text_widget.dart';
import '../widgets/no_bookings_widget.dart';

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

  Future<String> getUserName(String userId) async {
    UserModel userModel = await CloudFirestore().getUserData(userId);
    return userModel.name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getUserName(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, userData) {
          if (userData.hasData) {
            return userView();
          } else {
            return Container();
          }
        });
  }

  Widget adminView(String name) {
    return StreamBuilder<List<Booking>>(
        stream: CloudFirestore()
            .streamAllBookings(currentDate.month, currentDate.day),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              // Sort bookings by completion status (completed bookings at the bottom)
              snapshot.data!.removeWhere((booking) {
                print(booking.date);
                // Split the booking date into day and month
                List<String> dateParts = booking.date.split('/');
                int bookingDay = int.parse(dateParts[0]);
                int bookingMonth = int.parse(dateParts[1]);
                int bookingYear = dateParts.length == 3
                    ? int.parse(dateParts[2])
                    : DateTime.now().year;

                // Keep only if both day and month match exactly
                return !(bookingDay == currentDate.day &&
                    bookingMonth == currentDate.month &&
                    bookingYear == currentDate.year);
              });
            }
          }
          if (name == "BODY BUDDIES HEALTH & FITNESS") {
            name = "Mark";
          }
          if (!kDebugMode) {
            try {
              snapshot.data!.removeWhere((booking) => booking.trainer != name);
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          }
          return SizedBox(
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
                                icon: const Icon(
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
                                text: DateFormat.yMMMEd().format(currentDate),
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
                                icon: const Icon(
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
                                        .map((booking) => GestureDetector(
                                              onDoubleTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    TextEditingController
                                                        nameController =
                                                        TextEditingController();
                                                    return AlertDialog(
                                                      title:
                                                          Text('Update Name'),
                                                      content: TextField(
                                                        controller:
                                                            nameController,
                                                        decoration:
                                                            const InputDecoration(
                                                                hintText:
                                                                    "Enter new name"),
                                                      ),
                                                      actions: <Widget>[
                                                        ElevatedButton(
                                                          child: Text('Update'),
                                                          onPressed: () {
                                                            String newName =
                                                                nameController
                                                                    .text;
                                                            // Assuming there's a method in CloudFirestore class to update booking name
                                                            CloudFirestore()
                                                                .updateBookingName(
                                                              booking.date
                                                                  .split(
                                                                      "/")[1],
                                                              booking.date
                                                                  .split(
                                                                      "/")[0],
                                                              booking.id,
                                                              newName,
                                                            )
                                                                .then(
                                                                    (success) {
                                                              if (success) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Name updated successfully')),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Failed to update name')),
                                                                );
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: BookingWidget(
                                                isBooked: true,
                                                slots: [],
                                                booking: booking,
                                                isAdmin: true,
                                                month: 0,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )
                            : NoBookingsWidget(
                                message: "No Sessions Today",
                                showSubHeading: false,
                              )
                        : MediumTextWidget(text: "Loading...")
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget userView() {
    return FutureBuilder<UserModel>(
        future: CloudFirestore()
            .getUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            snapshot.data!.bookings.removeWhere((booking) {
              // Split the booking date into day and month
              List<String> dateParts = booking.date.split('/');
              int bookingDay = int.parse(dateParts[0]);
              int bookingMonth = int.parse(dateParts[1]);
              int bookingYear = dateParts.length == 3
                  ? int.parse(dateParts[2])
                  : DateTime.now().year;

              // Keep only if both day and month match exactly
              return !(bookingDay == currentDate.day &&
                  bookingMonth == currentDate.month &&
                  bookingYear == currentDate.year);
            });
          }
          return SizedBox(
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
                                icon: const Icon(
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
                                text: DateFormat.yMMMEd().format(currentDate),
                                fontSize: Dimensions.fontSize18,
                                color: darkGreen,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate = currentDate
                                        .add(const Duration(days: 1));
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ],
                    ),
                    snapshot.hasData
                        ? snapshot.data!.bookings.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: Dimensions.height35 * 5,
                                    bottom: Dimensions.height10 * 6),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: snapshot.data!.bookings
                                        .map((booking) => BookingWidget(
                                              isBooked: true,
                                              slots: const [],
                                              booking: booking,
                                              isAdmin: false,
                                              month: 0,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )
                            : NoBookingsWidget(
                                message: "You Have No Bookings",
                                showSubHeading: true)
                        : MediumTextWidget(text: "Loading...")
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget userInformationHeader() {
    return FutureBuilder<UserModel>(
        future: CloudFirestore()
            .getUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediumTextWidget(
                    text: getTodaysDate(),
                    color: darkGreen,
                    fontSize: Dimensions.fontSize14),
                SizedBox(
                    width: Dimensions.screenWidth / 2,
                    child:
                        MediumTextWidget(text: "Hi, ${snapshot.data!.name}")),
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

  DateTime getBookingAsDateTime(String time, String date) {
    List<String> dateAsList = date.split("/");
    String day = dateAsList.first.padLeft(2, '0');
    String month = formatMonth(dateAsList[1]);

    int year;
    if (dateAsList.length == 3) {
      // If year is included in the date
      year = int.parse(dateAsList[2]);
    } else {
      // If year is not included, determine based on the current month
      int currentYear = DateTime.now().year;

      // Use current year for future dates, previous year for past dates
      year = currentYear;
    }

    // Ensure the date string is formatted correctly
    String formattedDate = "$year-$month-$day $time:00";
    DateTime dateTime = DateTime.parse(formattedDate);
    return dateTime;
  }

  String formatMonth(String month) {
    return month.length > 1 ? month : "0${month}";
  }

  bool isBookingComplete(Booking booking) {
    return DateTime.now()
        .isAfter(getBookingAsDateTime(booking.time, booking.date));
  }
}
