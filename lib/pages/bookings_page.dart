import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<Widget> dates = [];
  final _currentDate = DateTime.now();

  @override
  void initState() {
    initDates(context);
    super.initState();
  }

  void initDates(BuildContext context) {
    if (dates.isEmpty)
      // ignore: curly_braces_in_flow_control_structures
      for (int i = 0; i < 16; i++) {
        final date = _currentDate.add(Duration(days: i));
        dates.add(dateWidget(
            date.day.toString(), daysOfWeek[date.weekday - 1].substring(0, 3)));
      }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MediumTextWidget(
              text: "March 2023",
              fontSize: Dimensions.fontSize18,
            ),
            SizedBox(
              height: Dimensions.height10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dates.map((e) => e).toList(),
                ),
              ),
            ),
            // BookingWidget(),
            // BookingWidget(),
            // BookingWidget(),
            // BookingWidget(),
          ],
        ),
      ),
    );
  }

  Widget dateWidget(String day, String weekDay) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 / 2.5),
      child: SizedBox(
        width: Dimensions.width10 * 4,
        height: Dimensions.height10 * 5.5,
        child: Card(
          color: darkGrey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.width10 / 2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MediumTextWidget(
                text: day,
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
    );
  }
}
