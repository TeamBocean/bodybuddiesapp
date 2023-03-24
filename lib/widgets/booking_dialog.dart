import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

void bookingDialog(BuildContext context) {
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
                                text: "12/03/2023",
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
                                text: "13:00 - 13:45",
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
                                  onPressed: () {},
                                  child: MediumTextWidget(
                                    text: "Use 1 Credit",
                                    fontSize: Dimensions.fontSize12,
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          Center(child: MediumTextWidget(text: "OR", fontSize: Dimensions.fontSize16,)),
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
                                  onPressed: () {},
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
