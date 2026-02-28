import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:bodybuddiesapp/widgets/no_bookings_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Booking>? _dayBookings;

  // Horizon ribbon scroll controller
  late ScrollController _horizonScrollController;

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
    _horizonScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  void _scrollToCurrentDate() {
    if (!_horizonScrollController.hasClients) return;
    _horizonScrollController.jumpTo(0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _horizonScrollController.dispose();
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
      timeSlot,
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
    return StreamBuilder<Bookings>(
      stream: CloudFirestore().streamBookedDates(
        FirebaseAuth.instance.currentUser!.uid,
        year: currentDay.year,
      ),
      builder: (context, bookingsSnapshot) {
        if (bookingsSnapshot.hasData) {
          bookings = bookingsSnapshot.data;
        }

        // Secondary stream: cross-reference the bookings-list (admin's source of truth)
        // This prevents double-bookings when the availability map is out of sync
        return StreamBuilder<List<Booking>>(
          stream: CloudFirestore().streamAllBookings(
            currentDay.month,
            currentDay.day,
            year: currentDay.year,
          ),
          builder: (context, dayBookingsSnapshot) {
            if (dayBookingsSnapshot.hasData) {
              _dayBookings = dayBookingsSnapshot.data;
            }

            _buildAvailableSlots();
            _buildDateWidgets();

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: StreamBuilder<UserModel>(
                  stream: CloudFirestore()
                      .streamUserData(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, userSnapshot) {
                    if (!bookingsSnapshot.hasData && !dayBookingsSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: bbAccent),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Editorial Header ──────────────────────────────────
                        _buildHeader(),
                        const SizedBox(height: 16),

                        // ── Horizon Timeline Ribbon ───────────────────────────
                        _buildHorizonRibbon(),
                        const SizedBox(height: 12),

                        // ── Slot List ─────────────────────────────────────────
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
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: slots.isEmpty
                                          ? [_buildEmptyState()]
                                          : _buildSlotList(userSnapshot),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build the slot list with separators between each slot
  List<Widget> _buildSlotList(AsyncSnapshot<UserModel> userSnapshot) {
    List<Widget> items = [];
    for (int i = 0; i < slots.length; i++) {
      bool isBooked = userSnapshot.data?.bookings
              .firstWhereOrNull(
                  (element) => element.isOnDate(currentDay)) !=
          null;

      items.add(
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: AbsorbPointer(
            key: ValueKey<bool>(isBooked),
            absorbing: isBooked,
            child: slots[i],
          ),
        ),
      );
    }
    return items;
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
        final bookingDate =
            "${currentDay.day}/${currentDay.month}/${currentDay.year}";

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

  /// Check if a time slot conflicts with existing bookings.
  /// Uses DUAL-SOURCE verification:
  ///   1. The availability map (bookings/{year}) — fast path
  ///   2. The bookings list (bookings-list) — ground truth (same as admin)
  /// This prevents double-bookings when the two stores are out of sync.
  bool _isTimeSlotConflicting(String time) {
    final bookingMinutes = _parseTimeToMinutes(time);

    // Source 1: Check the availability map
    if (bookings != null) {
      final dayStr = currentDay.day.toString();
      final monthStr = currentDay.month.toString();
      List<dynamic>? bookedTimes = bookings!.list[monthStr]?[dayStr];
      if (bookedTimes != null) {
        for (final existingTime in bookedTimes) {
          final existingMinutes = _parseTimeToMinutes(existingTime as String);
          final diff = (bookingMinutes - existingMinutes).abs();
          if (diff < 45) return true;
        }
      }
    }

    // Source 2: Check the bookings list (ground truth)
    if (_dayBookings != null) {
      for (final booking in _dayBookings!) {
        if (booking.time.isEmpty) continue;
        final existingMinutes = _parseTimeToMinutes(booking.time);
        final diff = (bookingMinutes - existingMinutes).abs();
        if (diff < 45) return true;
      }
    }

    return false;
  }

  int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void _buildDateWidgets() {
    dates.clear();
    for (int i = 0; i < 360; i++) {
      final date = _currentDate.add(Duration(days: i));
      dates.add(_horizonDateItem(
        date,
        daysOfWeek[date.weekday - 1].substring(0, 3),
        date.day == currentDay.day &&
            date.month == currentDay.month &&
            date.year == currentDay.year,
      ));
    }
  }

  // ─── Editorial Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiny all-caps title
          Text(
            "BOOK",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: bbTextMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(width: 16),
          // Coach filter — just the name, no box
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
                    return DropdownButton<String>(
                      value: selectedValue,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: bbTextMuted, size: 14),
                      dropdownColor: bbSurface,
                      style: GoogleFonts.plusJakartaSans(
                        color: bbTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      underline: const SizedBox(),
                      isDense: true,
                      onChanged: (String? newValue) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                      items: pts
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: GoogleFonts.plusJakartaSans()),
                        );
                      }).toList(),
                    );
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          const Spacer(),
          // Calendar — just text, no box
          GestureDetector(
            onTap: _showCalendarDialog,
            child: Text(
              "${months[currentDay.month - 1]} ${currentDay.year}",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: bbTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Horizon Timeline Ribbon ───────────────────────────────────────────────
  Widget _buildHorizonRibbon() {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          // The ultra-thin grey line
          Positioned(
            left: 20,
            right: 20,
            top: 28,
            child: Container(height: 0.25, color: bbBorder.withOpacity(0.4)),
          ),
          // Scrollable dates sitting ON the line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              controller: _horizonScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: dates.length,
              itemBuilder: (context, index) => dates[index],
            ),
          ),
          // Left fade
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [bbBackground, bbBackground.withOpacity(0)],
                ),
              ),
            ),
          ),
          // Right fade
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [bbBackground, bbBackground.withOpacity(0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Horizon Date Item ─────────────────────────────────────────────────────
  // Dates sit on the thin line. Current day has an "ink drop" marker.
  Widget _horizonDateItem(DateTime dateTime, String weekDay, bool isCurrent) {
    bool hasBookings = bookings?.list[dateTime.month.toString()]
            ?[dateTime.day.toString()] !=
        null;

    return GestureDetector(
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
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Weekday abbreviation
            Text(
              weekDay.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                color: isCurrent ? bbAccent : bbTextMuted,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            // Day number — weight change for current day
            Text(
              dateTime.day.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: isCurrent ? 22 : 18,
                color: isCurrent ? bbText : bbTextSecondary,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w300,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            // "Ink drop" marker for current day
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCurrent ? 6 : (hasBookings ? 4 : 0),
              height: isCurrent ? 6 : (hasBookings ? 4 : 0),
              decoration: BoxDecoration(
                color: isCurrent
                    ? bbText
                    : (hasBookings ? bbAccentAlt : Colors.transparent),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Typographic Empty State ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: NoBookingsWidget(
        message: "A day for rest.\nYou are clear for today.",
        showSubHeading: true,
        onViewTomorrow: () async {
          HapticFeedback.lightImpact();
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          await _onDateTap(tomorrow);
        },
        onExploreSchedule: () async {
          HapticFeedback.lightImpact();
          DateTime now = DateTime.now();
          DateTime nextMonday =
              now.add(Duration(days: (8 - now.weekday) % 7));
          if (nextMonday.weekday != DateTime.monday) {
            nextMonday = nextMonday.add(const Duration(days: 7));
          }
          await _onDateTap(nextMonday);
        },
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
  }

  double getOpacity(List<Booking> list) {
    Booking? booking =
        list.firstWhereOrNull((element) => element.isOnDate(currentDay));
    return booking != null ? 0.5 : 1;
  }

  bool isAlreadyBooked(Booking booking, Map bookings) {
    String month = booking.month.toString();
    String day = booking.day.toString();
    List<dynamic>? bookedTimes = bookings.containsKey(month)
        ? bookings[month][day]
        : [];
    return bookedTimes != null ? bookedTimes.contains(booking.time) : false;
  }
}
