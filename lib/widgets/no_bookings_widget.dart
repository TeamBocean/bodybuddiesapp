import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import 'medium_text_widget.dart';

class NoBookingsWidget extends StatelessWidget {
  String message;
  bool showSubHeading;

  NoBookingsWidget(
      {Key? key, required this.message, required this.showSubHeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Dimensions.fontSize20,
          ),
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Visibility(
          visible: showSubHeading,
          child: Visibility(
            visible: showSubHeading,
            child: MediumTextWidget(
              text: "Click On Bookings To Get Started",
              fontSize: Dimensions.fontSize14,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}
