import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/bookings.dart';
import '../models/user.dart';
import '../services/cloud_firestore.dart';
import '../utils/dimensions.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<Widget> dates = [];
  String selectedValue = "Mark";
  final DateFormat _dateFormat = DateFormat('HH:mm');

  String _day = DateTime.now().day.toString();
  String _month = DateTime.now().month.toString();
  DateTime currentDay = DateTime.now();
  final _currentDate = DateTime.now();
  DateTime startTimeOne = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 15, 0);

  Duration step = Duration(minutes: 15);
  List<Widget> slots = [];
  int currentDayPage = 365;
  PageController pageController = PageController(initialPage: 365);
  Bookings? bookings;
  bool loadedBookedDates = false;

  @override
  void initState() {
    loadBookedDates().whenComplete(() {
      setState(() {
        loadedBookedDates = true;
      });
      if (loadedBookedDates) {
        initDates(context);
      }
    });
    super.initState();
  }

  Future<bool> loadBookedDates() async {
    bookings = await CloudFirestore().getBookedDates("");

    return true;
  }

  void initDates(BuildContext context) {
    dates.clear();
    for (int i = 0; i < 360; i++) {
      final date = _currentDate.add(Duration(days: i));
      setState(() {
        dates.add(dateWidget(date, daysOfWeek[date.weekday - 1].substring(0, 3),
            date.day.toString() == _day && date.month.toString() == _month));
      });
    }

    setState(() {
      slots.clear();
      currentDay = DateTime.now().add(Duration(days: currentDayPage - 365));
      DateTime startTime = _getSessionsStartTime();
      DateTime endTime = _getSessionsEndTime();
      if (isCurrentDayNotWeekend()) {
        DateFormat df = new DateFormat('HH:mm');

        while (startTime.isBefore(endTime)) {
          DateTime timeIncrement = startTime.add(step);
          if (isAlreadyBooked(
                  Booking(
                    bookingName: "",
                    trainer: selectedValue,
                    price: 1,
                    date: currentDay.day.toString() +
                        "/" +
                        currentDay.month.toString(),
                    time: df
                        .format(timeIncrement.subtract(Duration(minutes: 15))),
                  ),
                  bookings != null ? bookings!.list : {}) ||
              isAlreadyBooked(
                  Booking(
                    bookingName: "",
                    price: 1,
                    trainer: selectedValue,
                    date: currentDay.day.toString() +
                        "/" +
                        currentDay.month.toString(),
                    time: df
                        .format(timeIncrement.subtract(Duration(minutes: 30))),
                  ),
                  bookings != null ? bookings!.list : {})) {
          } else {
            var uuid = Uuid();
            setState(() {
              slots.add(BookingWidget(
                isBooked: false,
                trainer: selectedValue,
                isAdmin: false,
                slots: slots,
                booking: Booking(
                  id: uuid.v1(),
                  bookingName: "",
                  trainer: selectedValue,
                  price: 1,
                  date: currentDay.day.toString() +
                      "/" +
                      currentDay.month.toString(),
                  time: df.format(timeIncrement),
                ),
                month: currentDay.month,
              ));
            });
          }

          startTime = timeIncrement;
        }
      } else if (selectedValue == "Mandalena") {
        while (startTime.isBefore(endTime)) {
          DateTime timeSlot = startTime.add(const Duration(minutes: 15));
          if (_isSlotAvailable(timeSlot)) {
            slots.add(_buildBookingWidget(timeSlot));
          }
          startTime = timeSlot;
        }
      }
    });
  }

  Widget _buildBookingWidget(DateTime timeSlot) {
    var uuid = const Uuid();
    return BookingWidget(
      isBooked: false,
      isAdmin: false,
      slots: slots,
      booking: Booking(
        id: uuid.v1(),
        bookingName: "",
        trainer: selectedValue,
        price: 1,
        date: "${currentDay.day}/${currentDay.month}/${currentDay.year}",
        time: _dateFormat.format(timeSlot),
      ),
      month: currentDay.month,
      trainer: selectedValue,
    );
  }

  bool _isSlotAvailable(DateTime timeSlot) {
    List<DateTime> timesToCheck = [
      timeSlot.add(const Duration(minutes: 15)),
      timeSlot.add(const Duration(minutes: 30)),
      timeSlot.subtract(const Duration(minutes: 15)),
      timeSlot.subtract(const Duration(minutes: 30)),
    ];

    return timesToCheck.every((time) => !_isAlreadyBooked(time));
  }

  bool _isAlreadyBooked(DateTime time) {
    if (bookings == null) return false;

    String date = "${time.day}/${time.month}";
    String timeString = _dateFormat.format(time);

    List<dynamic>? bookedTimes =
        bookings!.list[time.month.toString()]?[time.day.toString()];
    return bookedTimes != null && bookedTimes.contains(timeString);
  }

  bool isCurrentDayNotWeekend() {
    return currentDay.weekday != 6 &&
        currentDay.weekday != 7 &&
        (selectedValue != "Mandalena");
  }

  DateTime _getSessionsStartTime() {
    return selectedValue == "Mandalena"
        ? DateTime(currentDay.year, currentDay.month, currentDay.day, 6, 45)
        : (currentDay.weekday.isEven
            ? DateTime(
                currentDay.year, currentDay.month, currentDay.day, 14, 15)
            : DateTime(
                currentDay.year, currentDay.month, currentDay.day, 6, 30));
  }

  DateTime _getSessionsEndTime() {
    return selectedValue == "Mandalena"
        ? DateTime(currentDay.year, currentDay.month, currentDay.day, 21, 00)
        : DateTime(currentDay.year, currentDay.month, currentDay.day, 20, 30);
  }

  @override
  Widget build(BuildContext context) {
    initDates(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: StreamBuilder<UserModel>(
            stream: CloudFirestore()
                .streamUserData(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimensions.width15),
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
                    ),
                    Expanded(
                      child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentDayPage = index;
                              _day = DateTime.now()
                                  .add(Duration(days: currentDayPage - 365))
                                  .day
                                  .toString();

                              _month = DateTime.now()
                                  .add(Duration(days: currentDayPage - 365))
                                  .month
                                  .toString();
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: Dimensions.height50 +
                                      Dimensions.height20),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height -
                                    (Dimensions.height50 * 4 +
                                        Dimensions.height10 * 8),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: slots.length == 0
                                        ? [noBookings()]
                                        : slots
                                            .map((booking) => AbsorbPointer(
                                                  absorbing: snapshot.data!.bookings.firstWhereOrNull((element) =>
                                                              formatBookingDate(
                                                                          element)
                                                                      .day ==
                                                                  currentDay
                                                                      .add(Duration(
                                                                          days: currentDayPage -
                                                                              365))
                                                                      .day &&
                                                              formatBookingDate(
                                                                          element)
                                                                      .month ==
                                                                  currentDay
                                                                      .add(Duration(
                                                                          days: currentDayPage -
                                                                              365))
                                                                      .month) !=
                                                          null
                                                      ? true
                                                      : false,
                                                  child: booking,
                                                ))
                                            .toList(),
                                  ),
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                );
              } else {
                return Text("Loading");
              }
            }),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        FutureBuilder<List<dynamic>>(
            future: CloudFirestore().getAllPTs(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<String> pts = snapshot.data!
                    .map((item) => item['name'].toString())
                    .toList();
                pts.add("Mark");
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: EdgeInsets.only(left: Dimensions.width10),
                      child: DropdownButton<String>(
                        value: selectedValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).iconTheme.color ?? Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        dropdownColor: Theme.of(context).cardTheme.color,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                          initDates(context);
                        },
                        items:
                            pts.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            }),
        Align(
          alignment: Alignment.center,
          child: MediumTextWidget(
            text: "${months[currentDay.month - 1]} ${currentDay.year}",
            fontSize: Dimensions.fontSize18,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: Dimensions.width15),
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: _showCalendarDialog,
              splashRadius: 0.1,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 22, maxWidth: 22),
              icon: Icon(
                Icons.calendar_month,
                color: Theme.of(context).iconTheme.color ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _showCalendarDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: _currentDate,
      lastDate: DateTime(_currentDate.year, 12, 30),
    );

    if (pickedDate != null) {
      _onDateTap(pickedDate);
    }
  }

  void _onDateTap(DateTime date) {
    setState(() {
      int pageIndex = date.difference(_currentDate).inDays;
      if (pageIndex < 0) pageIndex += 365;
      pageController.jumpToPage(pageIndex + 365);
      currentDay = date;
      initDates(context);
    });
  }

  double getOpacity(List<Booking> list) {
    Booking? booking = list.firstWhereOrNull((element) =>
        formatBookingDate(element).day ==
        currentDay.add(Duration(days: currentDayPage - 365)).day);
    return booking != null ? 0.5 : 1;
  }

  DateTime formatBookingDate(Booking booking) {
    return DateTime(
      DateTime.now().add(Duration(days: currentDayPage - 365)).year,
      int.parse(booking.date.split('/')[0]),
      int.parse(booking.date.split('/')[0]),
    );
  }

  Widget dateWidget(DateTime dateTime, String weekDay, bool isCurrent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 / 2.5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            dateTime.day != DateTime.now().day ||
                    dateTime.month != DateTime.now().month
                ? setState(() {
                    pageController.jumpToPage(
                        dateTime.difference(DateTime.now()).inDays < 0
                            ? dateTime.difference(DateTime.now()).inDays + 365
                            : dateTime.difference(DateTime.now()).inDays + 366);
                  })
                : pageController.jumpToPage(365);
            _day = dateTime.day.toString();
            _month = dateTime.month.toString();
            currentDay = dateTime;
            initDates(context);
          });
        },
        child: SizedBox(
          width: Dimensions.width10 * 4,
          height: Dimensions.height10 * 5.5,
          child: Card(
            color: isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.width10 / 2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MediumTextWidget(
                  text: dateTime.day.toString(),
                  fontSize: Dimensions.fontSize10,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
                MediumTextWidget(
                  text: weekDay,
                  fontSize: Dimensions.fontSize10,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showCalendarDialog() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year, 12, 30));

    if (pickedDate != null) {
      setState(() {
        pickedDate.day != DateTime.now().day ||
                pickedDate.month != DateTime.now().month
            ? setState(() {
                pageController.jumpToPage(
                    pickedDate.difference(DateTime.now()).inDays < 0
                        ? pickedDate.difference(DateTime.now()).inDays + 365
                        : pickedDate.difference(DateTime.now()).inDays + 366);
              })
            : pageController.jumpToPage(365);
        _day = pickedDate.day.toString();
        _month = pickedDate.month.toString();
        currentDay = pickedDate;
        initDates(context);
      });
    }
  }

  Widget noBookings() {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.height10 * 10),
      child: Column(
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
            text: "No Sessions available today!",
            fontSize: Dimensions.fontSize20,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
          SizedBox(
            height: Dimensions.height10,
          ),
          MediumTextWidget(
            text: "We're back on Monday",
            fontSize: Dimensions.fontSize12,
            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          )
        ],
      ),
    );
  }

  bool isAlreadyBooked(Booking booking, Map bookings) {
    List<dynamic>? bookedTimes = bookings
            .containsKey(booking.date.split('/').last)
        ? bookings[booking.date.split('/').last][booking.date.split('/').first]
        : [];
    return bookedTimes != null ? bookedTimes.contains(booking.time) : false;
  }
}
