import 'package:bodybuddiesapp/services/authentication.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/booking_dialog.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({Key? key}) : super(key: key);

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15, vertical: Dimensions.height10/2),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimensions.height10 * 12,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.width15)
          ),
          color: darkGrey,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width15, vertical: Dimensions.width15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MediumTextWidget(
                      text: "13:00 - 13:45",
                      fontSize: Dimensions.fontSize16,
                    ),
                    MediumTextWidget(
                      text: "Home Workout Session",
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
                        SizedBox(
                          width: Dimensions.width15,
                        ),
                        SizedBox(
                          width: Dimensions.width15 * 4.5,
                          height: Dimensions.height10 * 2,
                          child: Card(
                            margin: EdgeInsets.all(0),
                            elevation: 0,
                            color: darkGreen,
                            child: Center(
                              child: MediumTextWidget(
                                text: "Group",
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
                      text: "Monday\n15 Apr",
                      fontSize: Dimensions.fontSize14,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Dimensions.width15 * 4.5,
                          height: Dimensions.height10 * 2,
                          child: ElevatedButton(
                            onPressed: () => Authentication.signOut(context: context),
                            // onPressed: () => bookingDialog(context),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white
                            ),
                            child: Center(
                              child: MediumTextWidget(
                                text: "Book",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
