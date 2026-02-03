import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  List<Widget> dates = [];
  String selectedValue = "Mark";
  final DateFormat _dateFormat = DateFormat('HH:mm');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime currentDay = DateTime.now();
  final _currentDate = DateTime.now();
  DateTime startTimeOne = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 15, 0);

  Duration step = const Duration(minutes: 15);
  List<Widget> slots = [];
  int currentDayPage = 365;
  PageController pageController = PageController(initialPage: 365);
  Bookings? bookings;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    // Note: Booking data is now loaded via StreamBuilder in build(), not here
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      timeSlot, // CRITICAL: Check the slot itself first!
      timeSlot.add(const Duration(minutes: 15)),
      timeSlot.add(const Duration(minutes: 30)),
      timeSlot.subtract(const Duration(minutes: 15)),
      timeSlot.subtract(const Duration(minutes: 30)),
    ];

    return timesToCheck.every((time) => !_isAlreadyBooked(time));
  }

  bool _isAlreadyBooked(DateTime time) {
    if (bookings == null) return false;

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
    // Use StreamBuilder for real-time booking updates to prevent double-booking
    return StreamBuilder<Bookings>(
      stream: CloudFirestore().streamBookedDates(
        FirebaseAuth.instance.currentUser!.uid,
        year: currentDay.year,
      ),
      builder: (context, bookingsSnapshot) {
        // Update the local bookings reference when stream updates
        if (bookingsSnapshot.hasData) {
          bookings = bookingsSnapshot.data;
        }
        
        // Rebuild available slots based on current booking data
        _buildAvailableSlots();
        _buildDateWidgets();
        
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: StreamBuilder<UserModel>(
              stream: CloudFirestore()
                  .streamUserData(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, userSnapshot) {
                if (!bookingsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: Dimensions.height10),
                    SizedBox(
                      height: Dimensions.height10 * 6,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width15),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dates.map((date) => date).toList(),
                              ),
                            ),
                          ),
                          // Gradient fade effect for horizontal scroll
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: Dimensions.width20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: Dimensions.width20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height15),
                    Padding(
                      padding: EdgeInsets.only(left: Dimensions.width20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: MediumTextWidget(
                          text: "Available Sessions",
                          fontSize: Dimensions.fontSize18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: (index) async {
                          HapticFeedback.lightImpact();
                          setState(() {
                            currentDayPage = index;
                            currentDay = DateTime.now()
                                .add(Duration(days: currentDayPage - 365));
                          });
                          // Year change is handled automatically by StreamBuilder
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: Dimensions.height50 + Dimensions.height20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height -
                                  (Dimensions.height50 * 4 + Dimensions.height10 * 8),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: slots.isEmpty
                                      ? [noBookings()]
                                      : slots.map((booking) {
                                          bool isBooked = userSnapshot.data?.bookings.firstWhereOrNull((element) =>
                                              element.isOnDate(currentDay)) != null;
                                          
                                          return AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            child: AbsorbPointer(
                                              key: ValueKey<bool>(isBooked),
                                              absorbing: isBooked,
                                              child: booking,
                                            ),
                                          );
                                        }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Build available slots based on current booking data
  void _buildAvailableSlots() {
    slots.clear();
    DateTime startTime = _getSessionsStartTime();
    DateTime endTime = _getSessionsEndTime();
    
    if (isCurrentDayNotWeekend()) {
      DateFormat df = DateFormat('HH:mm');
      
      while (startTime.isBefore(endTime)) {
        DateTime timeIncrement = startTime.add(step);
        final bookingDate = "${currentDay.day}/${currentDay.month}/${currentDay.year}";
        
        // Check if this slot conflicts with any 45-minute session
        if (!_isTimeSlotConflicting(df.format(timeIncrement))) {
          var uuid = const Uuid();
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
              date: bookingDate,
              time: df.format(timeIncrement),
            ),
            month: currentDay.month,
          ));
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
  }
  
  /// Check if a time slot conflicts with existing bookings (45-min window)
  bool _isTimeSlotConflicting(String time) {
    if (bookings == null) return false;
    
    final bookingMinutes = _parseTimeToMinutes(time);
    final dayStr = currentDay.day.toString();
    final monthStr = currentDay.month.toString();
    
    List<dynamic>? bookedTimes = bookings!.list[monthStr]?[dayStr];
    if (bookedTimes == null) return false;
    
    for (final existingTime in bookedTimes) {
      final existingMinutes = _parseTimeToMinutes(existingTime as String);
      final diff = (bookingMinutes - existingMinutes).abs();
      // Sessions are 45 minutes, so block if within 45 minutes
      if (diff < 45) {
        return true;
      }
    }
    return false;
  }
  
  int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
  
  /// Build date widgets for the horizontal date selector
  void _buildDateWidgets() {
    dates.clear();
    for (int i = 0; i < 360; i++) {
      final date = _currentDate.add(Duration(days: i));
      dates.add(dateWidget(
        date,
        daysOfWeek[date.weekday - 1].substring(0, 3),
        date.day == currentDay.day &&
            date.month == currentDay.month &&
            date.year == currentDay.year,
      ));
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
      child: Stack(
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
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: selectedValue,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          dropdownColor: Theme.of(context).cardTheme.color,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black,
                            fontSize: Dimensions.fontSize16,
                          ),
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              selectedValue = newValue!;
                            });
                            // Slots rebuild automatically via StreamBuilder
                          },
                          items:
                              pts.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text("Coach: $value"),
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
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: _showCalendarDialog,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: Dimensions.iconSize11,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: Dimensions.width5),
                    MediumTextWidget(
                      text:
                          "${months[currentDay.month - 1]} ${currentDay.year}",
                      fontSize: Dimensions.fontSize16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCalendarDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDay,
      firstDate: _currentDate,
      lastDate: DateTime(_currentDate.year + 1, 12, 30),
    );

    if (pickedDate != null) {
      await _onDateTap(pickedDate);
    }
  }

  Future<void> _onDateTap(DateTime date) async {
    setState(() {
      int pageIndex = date.difference(_currentDate).inDays;
      if (pageIndex < 0) pageIndex += 365;
      pageController.jumpToPage(pageIndex + 365);
      currentDay = date;
    });
    // Slots rebuild automatically via StreamBuilder when currentDay changes
  }

  double getOpacity(List<Booking> list) {
    Booking? booking = list.firstWhereOrNull((element) =>
        element.isOnDate(currentDay));
    return booking != null ? 0.5 : 1;
  }

  Widget dateWidget(DateTime dateTime, String weekDay, bool isCurrent) {
    bool hasBookings = bookings?.list[dateTime.month.toString()]
            ?[dateTime.day.toString()] !=
        null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 / 2.5),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          setState(() {
            if (dateTime.day != DateTime.now().day ||
                dateTime.month != DateTime.now().month ||
                dateTime.year != DateTime.now().year) {
              int diff = dateTime.difference(DateTime.now()).inDays;
              pageController.jumpToPage(diff < 0 ? diff + 365 : diff + 366);
            } else {
              pageController.jumpToPage(365);
            }
            currentDay = dateTime;
          });
          // Slots rebuild automatically via StreamBuilder when currentDay changes
        },
        child: SizedBox(
          width: Dimensions.width10 * 4,
          height: Dimensions.height10 * 5.5,
          child: Card(
            color: isCurrent
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardTheme.color,
            elevation: isCurrent ? 4 : 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.width10 / 2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MediumTextWidget(
                  text: dateTime.day.toString(),
                  fontSize: Dimensions.fontSize14,
                  color: isCurrent
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                ),
                MediumTextWidget(
                  text: weekDay,
                  fontSize: Dimensions.fontSize12,
                  color: isCurrent
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                ),
                if (hasBookings)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget noBookings() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
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
              text: "Looks like today's fully booked!",
              fontSize: Dimensions.fontSize20,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
            SizedBox(height: Dimensions.height10),
            MediumTextWidget(
              text: "But we'll be back on Monday – see you then!",
              fontSize: Dimensions.fontSize14,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            ),
            SizedBox(height: Dimensions.height20),
            ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.lightImpact();
                // Find next Monday
                DateTime now = DateTime.now();
                DateTime nextMonday =
                    now.add(Duration(days: (8 - now.weekday) % 7));
                if (nextMonday.weekday != DateTime.monday) {
                  nextMonday = nextMonday.add(const Duration(days: 7));
                }
                await _onDateTap(nextMonday);
              },
              icon: const Icon(Icons.add),
              label: const Text("Quick Book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isAlreadyBooked(Booking booking, Map bookings) {
    // Use centralized date parsing from Booking model
    String month = booking.month.toString();
    String day = booking.day.toString();
    
    List<dynamic>? bookedTimes = bookings.containsKey(month)
        ? bookings[month][day]
        : [];
    return bookedTimes != null ? bookedTimes.contains(booking.time) : false;
  }
}
