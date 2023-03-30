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
  String _day = DateTime.now().day.toString();
  DateTime currentDay = DateTime.now();
  final _currentDate = DateTime.now();

  @override
  void initState() {
    initDates(context);
    super.initState();
  }

  void initDates(BuildContext context) {
    dates.clear();
    for (int i = 0; i < 16; i++) {
      final date = _currentDate.add(Duration(days: i));
      setState(() {
        dates.add(dateWidget(date, daysOfWeek[date.weekday - 1].substring(0, 3),
            date.day.toString() == _day));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initDates(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Column(
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
                      onPressed: () {},
                      splashRadius: 0.1,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 22, maxWidth: 22),
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
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
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
            )
            // BookingWidget(),
            // BookingWidget(),
            // BookingWidget(),
            // BookingWidget(),
          ],
        ),
      ),
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
}
