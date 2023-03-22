import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MediumTextWidget(
                              text: "March, 13",
                              color: darkGreen,
                              fontSize: Dimensions.fontSize14),
                          MediumTextWidget(text: "Hi, Mark"),
                          MediumTextWidget(
                            text: "Remaining Credits: 12",
                            fontSize: Dimensions.fontSize14,
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        radius: Dimensions.width27,
                        child: MediumTextWidget(
                          text: "M",
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
              Column(
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          primary: darkGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.width10))),
                      child: MediumTextWidget(
                        text: "Book Now",
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
