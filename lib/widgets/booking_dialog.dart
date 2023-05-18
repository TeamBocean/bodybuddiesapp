import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/pages/credits_page.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/cloud_firestore.dart';

void bookingDialog(BuildContext context, Booking booking, int month) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
                          Divider(
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
                                text: "${booking.date}",
                                fontSize: Dimensions.fontSize14,
                              ),
                            ],
                          ),
                          Divider(
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
                                text: "${booking.time}",
                                fontSize: Dimensions.fontSize14,
                              ),
                            ],
                          ),
                          Divider(
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
                          Divider(
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
                          Divider(
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: Dimensions.height30,
                          ),
                          StreamBuilder<UserModel>(
                              stream: CloudFirestore().streamUserData(
                                  FirebaseAuth.instance.currentUser!.uid),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: Dimensions.width10 * 20,
                                      height: Dimensions.height50,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: darkGreen,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.width15))),
                                          onPressed: () {
                                            if (snapshot.data!.credits > 0) {
                                              CloudFirestore().addBooking(
                                                  booking,
                                                  month,
                                                  FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .displayName !=
                                                          null
                                                      ? FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .displayName!
                                                      : "");
                                              CloudFirestore().decreaseCredits(
                                                  1,
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid);
                                              Navigator.pop(context, 'dialog');
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "You are out of credits")));
                                            }
                                          },
                                          child: MediumTextWidget(
                                            text: "Use 1 Credit",
                                            fontSize: Dimensions.fontSize12,
                                            color: Colors.black,
                                          )),
                                    ),
                                  );
                                } else {
                                  return Text("Loading..");
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
                                      primary: darkGreen,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.width15))),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreditsPage()));
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
          ));
}
