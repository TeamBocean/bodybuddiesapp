import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:bodybuddiesapp/widgets/no_bookings_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/cloud_firestore.dart';
import '../services/booking_api.dart';
import '../utils/dimensions.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  static const int _quickDateCount = 14;

  List<Widget> dates = [];
  String selectedValue = "Mark";
  String selectedTrainerId = "mark";
  final DateFormat _dateFormat = DateFormat('HH:mm');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Future<List<dynamic>> _trainersFuture;

  DateTime currentDay = DateTime.now();
  final _currentDate = DateTime.now();

  Duration step = const Duration(minutes: 15);
  // Raw availability for the current day. Widgets are built lazily in
  // _buildSlotList so we can flag them once we know the user's own bookings.
  final List<Booking> _slotData = [];
  int currentDayPage = 365;
  PageController pageController = PageController(initialPage: 365);
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
    _trainersFuture = CloudFirestore().getAllPTs();

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

  Booking _bookingFor(DateTime timeSlot) {
    final time = _dateFormat.format(timeSlot);
    return Booking(
      id: 'slot_${selectedTrainerId}_${currentDay.year}_'
          '${currentDay.month}_${currentDay.day}_${time.replaceAll(':', '')}',
      bookingName: "",
      trainer: selectedValue,
      trainerId: selectedTrainerId,
      price: 1,
      date: "${currentDay.day}/${currentDay.month}/${currentDay.year}",
      time: time,
    );
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
    return StreamBuilder<List<Booking>>(
      stream: CloudFirestore().streamDayAvailability(
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
                if (!dayBookingsSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: bbAccent),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header and booking controls.
                    _buildHeader(),
                    const SizedBox(height: 18),

                    // Nearby date strip.
                    _buildHorizonRibbon(),
                    const SizedBox(height: 14),

                    // Available times.
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: (index) async {
                          HapticFeedback.lightImpact();
                          setState(() {
                            currentDayPage = index;
                            currentDay = _currentDate
                                .add(Duration(days: currentDayPage - 365));
                          });
                        },
                        itemBuilder: (context, index) {
                          final List<Widget> children = _slotData.isEmpty
                              ? [
                                  _buildBookingSummary(userSnapshot),
                                  _buildEmptyState(),
                                ]
                              : _buildSlotList(userSnapshot);

                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    Dimensions.height50 + Dimensions.height20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height -
                                  (Dimensions.height50 * 4 +
                                      Dimensions.height10 * 8),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(children: children),
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
  }

  List<Widget> _buildSlotList(AsyncSnapshot<UserModel> userSnapshot) {
    final Booking? existing = userSnapshot.data?.bookings
        .firstWhereOrNull((element) => element.isOnDate(currentDay));

    List<Widget> items = [_buildBookingSummary(userSnapshot)];
    if (existing != null) {
      items.add(_buildAlreadyBookedBanner(existing));
    }

    final groupedSlots = _groupSlotsByPeriod(_slotData);
    groupedSlots.forEach((period, slots) {
      items.add(_buildTimeGroupHeader(period, slots.length));
      for (final booking in slots) {
        items.add(
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: BookingWidget(
              key: ValueKey('${booking.trainer}-${booking.time}'),
              isBooked: false,
              trainer: selectedValue,
              isAdmin: false,
              booking: booking,
              month: currentDay.month,
            ),
          ),
        );
      }
    });

    return items;
  }

  Widget _buildBookingSummary(AsyncSnapshot<UserModel> userSnapshot) {
    final credits = userSnapshot.data?.credits;
    final slotCopy = _slotData.length == 1 ? "time" : "times";

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bbBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bbAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bbAccent.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: bbAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pick a session time",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: bbText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_formatFullDate(currentDay)} with $selectedValue",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: bbTextSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryPill(
                icon: Icons.schedule_rounded,
                label: "45 min",
              ),
              _summaryPill(
                icon: Icons.event_available_rounded,
                label: _slotData.isEmpty
                    ? "No times open"
                    : "${_slotData.length} $slotCopy open",
              ),
              if (credits != null)
                _summaryPill(
                  icon: Icons.confirmation_number_outlined,
                  label: "$credits ${credits == 1 ? 'credit' : 'credits'}",
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Tap a time to review the details before your credit is used.",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: bbTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bbCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bbBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: bbTextSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: bbText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGroupHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: bbText,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bbAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "$count",
              style: GoogleFonts.inter(
                fontSize: 10,
                color: bbAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Divider(color: bbBorder, thickness: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Booking>> _groupSlotsByPeriod(List<Booking> slots) {
    final Map<String, List<Booking>> groups = {
      "MORNING": [],
      "AFTERNOON": [],
      "EVENING": [],
    };

    for (final booking in slots) {
      groups[_periodForTime(booking.time)]!.add(booking);
    }

    groups.removeWhere((_, bookings) => bookings.isEmpty);
    return groups;
  }

  String _periodForTime(String time) {
    final minutes = _parseTimeToMinutes(time);
    if (minutes < 12 * 60) return "MORNING";
    if (minutes < 17 * 60) return "AFTERNOON";
    return "EVENING";
  }

  Widget _buildAlreadyBookedBanner(Booking existing) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bbAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bbAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: bbAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "You already have a session today at ${existing.time}. "
              "You can still reserve another available time.",
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: bbTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build available slots based on current booking data
  void _buildAvailableSlots() {
    _slotData.clear();
    DateTime startTime = _getSessionsStartTime();
    DateTime endTime = _getSessionsEndTime();

    if (isCurrentDayNotWeekend()) {
      while (startTime.isBefore(endTime)) {
        DateTime timeIncrement = startTime.add(step);
        if (!_shouldShowSlot(timeIncrement)) {
          startTime = timeIncrement;
          continue;
        }

        if (!_isTimeSlotConflicting(_dateFormat.format(timeIncrement))) {
          _slotData.add(_bookingFor(timeIncrement));
        }

        startTime = timeIncrement;
      }
    } else if (selectedValue == "Mandalena") {
      while (startTime.isBefore(endTime)) {
        DateTime timeSlot = startTime.add(const Duration(minutes: 15));
        if (_shouldShowSlot(timeSlot) &&
            !_isTimeSlotConflicting(_dateFormat.format(timeSlot))) {
          _slotData.add(_bookingFor(timeSlot));
        }
        startTime = timeSlot;
      }
    }
  }

  /// Checks the server-published, trainer-aware day projection. The booking
  /// command validates the same interval again before committing.
  bool _isTimeSlotConflicting(String time) {
    final bookingMinutes = _parseTimeToMinutes(time);

    // The public booking list is the canonical availability source. The legacy
    // availability map is not trainer-aware and must not block another coach.
    if (_dayBookings != null) {
      for (final booking in _dayBookings!) {
        final bookingTrainerId = booking.trainerId.isNotEmpty
            ? booking.trainerId
            : _normalizeTrainerId(booking.trainer);
        if (bookingTrainerId != selectedTrainerId) continue;
        if (booking.time.isEmpty) continue;
        final existingMinutes = _parseTimeToMinutes(booking.time);
        if (booking.isBlock && booking.endTime.isNotEmpty) {
          final blockEnd = _parseTimeToMinutes(booking.endTime);
          final requestedEnd = bookingMinutes + 45;
          if (bookingMinutes < blockEnd && requestedEnd > existingMinutes) {
            return true;
          }
          continue;
        }
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

  String _normalizeTrainerId(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]+'), '_');
  }

  bool _shouldShowSlot(DateTime timeSlot) {
    return timeSlot.isAfter(DateTime.now());
  }

  void _buildDateWidgets() {
    dates.clear();
    final startDate = _dateStripStartDate();

    for (int i = 0; i < _quickDateCount; i++) {
      final date = startDate.add(Duration(days: i));
      dates.add(_horizonDateItem(
        date,
        daysOfWeek[date.weekday - 1].substring(0, 3),
        date.day == currentDay.day &&
            date.month == currentDay.month &&
            date.year == currentDay.year,
      ));
    }
  }

  DateTime _dateStripStartDate() {
    final today =
        DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final selected =
        DateTime(currentDay.year, currentDay.month, currentDay.day);
    final selectedOffset = selected.difference(today).inDays;

    if (selectedOffset <= 5) return today;

    return selected.subtract(const Duration(days: 3));
  }

  // Header.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Book a session",
            style: GoogleFonts.inter(
              fontSize: 28,
              color: bbText,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose your coach, then reserve an available 45 minute slot.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: bbTextSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              FutureBuilder<List<dynamic>>(
                future: _trainersFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: bbAccent,
                        strokeWidth: 1.5,
                      ),
                    );
                  }

                  List<String> pts = snapshot.data!
                      .map((item) => item['name'].toString())
                      .toList();
                  if (!pts.contains("Mark")) pts.add("Mark");

                  return Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bbCard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: bbBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline,
                            size: 15, color: bbTextSecondary),
                        const SizedBox(width: 7),
                        DropdownButton<String>(
                          value: selectedValue,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: bbTextSecondary, size: 18),
                          dropdownColor: bbSurface,
                          style: GoogleFonts.inter(
                            color: bbText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          underline: const SizedBox(),
                          isDense: true,
                          onChanged: (String? newValue) {
                            if (newValue == null) return;
                            HapticFeedback.lightImpact();
                            setState(() {
                              selectedValue = newValue;
                              final matches = snapshot.data!.where(
                                (item) => item['name'].toString() == newValue,
                              );
                              selectedTrainerId = matches.isEmpty
                                  ? _normalizeTrainerId(newValue)
                                  : (matches.first['id']
                                              ?.toString()
                                              .isNotEmpty ==
                                          true
                                      ? matches.first['id'].toString()
                                      : _normalizeTrainerId(newValue));
                            });
                          },
                          items:
                              pts.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.inter()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  button: true,
                  label: "Open calendar",
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _showCalendarDialog,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: bbCard,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: bbBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 15, color: bbTextSecondary),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              "${months[currentDay.month - 1]} ${currentDay.year}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: bbText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (CloudFirestore().isEmployee() ||
              CloudFirestore().isDeveloper()) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showBlockManager,
                icon: const Icon(Icons.block_rounded, size: 17),
                label: const Text("Block or reopen times"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Nearby date strip.
  Widget _buildHorizonRibbon() {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        controller: _horizonScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) => dates[index],
      ),
    );
  }

  // Date strip item.
  Widget _horizonDateItem(DateTime dateTime, String weekDay, bool isCurrent) {
    final hasBookings = _hasKnownBookings(dateTime);
    final isTrainingDay = _isTrainingDay(dateTime);
    final label = _dateAvailabilityLabel(dateTime);

    return Semantics(
      button: true,
      selected: isCurrent,
      label: "${DateFormat('EEEE d MMMM').format(dateTime)}, $label",
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          await _onDateTap(dateTime);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 74,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isCurrent ? bbAccent : bbSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCurrent ? bbAccent : bbBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekDay.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isCurrent ? bbOnAccent : bbTextMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                dateTime.day.toString(),
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: isCurrent ? bbOnAccent : bbText,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? bbOnAccent
                          : hasBookings
                              ? bbAccentAlt
                              : isTrainingDay
                                  ? bbAccent
                                  : bbTextMuted.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: isCurrent ? bbOnAccent : bbTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTrainingDay(DateTime date) {
    return selectedValue == "Mandalena" ||
        (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday);
  }

  bool _hasKnownBookings(DateTime date) {
    if (!_isSameDate(date, currentDay) || _dayBookings == null) return false;
    return _dayBookings!.any((booking) {
      final trainerId = booking.trainerId.isNotEmpty
          ? booking.trainerId
          : _normalizeTrainerId(booking.trainer);
      return trainerId == selectedTrainerId;
    });
  }

  String _dateAvailabilityLabel(DateTime date) {
    if (!_isTrainingDay(date)) return "Rest";
    if (_hasKnownBookings(date)) return "Limited";
    return "Open";
  }

  String _formatFullDate(DateTime date) {
    return DateFormat('EEE, d MMM').format(date);
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
          DateTime nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
          if (nextMonday.weekday != DateTime.monday) {
            nextMonday = nextMonday.add(const Duration(days: 7));
          }
          await _onDateTap(nextMonday);
        },
      ),
    );
  }

  Future<void> _showCalendarDialog() async {
    DateTime visibleMonth = DateTime(currentDay.year, currentDay.month, 1);
    DateTime selectedDate = currentDay;

    final pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _buildCalendarSheet(
              context: context,
              visibleMonth: visibleMonth,
              selectedDate: selectedDate,
              onMonthChanged: (date) {
                setModalState(() {
                  visibleMonth = date;
                });
              },
              onDateSelected: (date) {
                setModalState(() {
                  selectedDate = date;
                });
              },
            );
          },
        );
      },
    );

    if (pickedDate != null) {
      await _onDateTap(pickedDate);
    }
  }

  Widget _buildCalendarSheet({
    required BuildContext context,
    required DateTime visibleMonth,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onMonthChanged,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    final monthLabel = DateFormat('MMMM yyyy').format(visibleMonth);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: bbSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: bbBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select date",
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          color: bbText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Available days update for $selectedValue.",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: bbTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: bbText),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: bbCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: bbBorder, width: 1),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _canShowPreviousMonth(visibleMonth)
                        ? () => onMonthChanged(
                              DateTime(
                                visibleMonth.year,
                                visibleMonth.month - 1,
                                1,
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: bbText,
                    disabledColor: bbTextMuted.withOpacity(0.35),
                  ),
                  Expanded(
                    child: Text(
                      monthLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: bbText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onMonthChanged(
                      DateTime(
                        visibleMonth.year,
                        visibleMonth.month + 1,
                        1,
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: bbText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: daysOfWeek
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day.substring(0, 3).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: bbTextMuted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            _buildCalendarGrid(
              visibleMonth: visibleMonth,
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, selectedDate),
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid({
    required DateTime visibleMonth,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final leadingBlanks = firstDay.weekday - 1;
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final itemCount = leadingBlanks + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 6,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < leadingBlanks) return const SizedBox();

        final day = index - leadingBlanks + 1;
        final date = DateTime(visibleMonth.year, visibleMonth.month, day);

        return _calendarDayCell(
          date: date,
          isSelected: _isSameDate(date, selectedDate),
          onTap: () => onDateSelected(date),
        );
      },
    );
  }

  Widget _calendarDayCell({
    required DateTime date,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final today =
        DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final isPast = date.isBefore(today);
    final isTrainingDay = _isTrainingDay(date);
    final hasBookings = _hasKnownBookings(date);

    return Semantics(
      button: !isPast,
      selected: isSelected,
      enabled: !isPast,
      label:
          "${DateFormat('EEEE d MMMM').format(date)}, ${_dateAvailabilityLabel(date)}",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isPast ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? bbAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? bbAccent
                  : hasBookings
                      ? bbAccentAlt.withOpacity(0.35)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isPast
                      ? bbTextMuted.withOpacity(0.35)
                      : isSelected
                          ? bbOnAccent
                          : bbText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected
                      ? bbOnAccent
                      : isPast
                          ? Colors.transparent
                          : hasBookings
                              ? bbAccentAlt
                              : isTrainingDay
                                  ? bbAccent
                                  : bbTextMuted.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canShowPreviousMonth(DateTime visibleMonth) {
    final currentMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    return visibleMonth.isAfter(currentMonth);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> _showBlockManager() async {
    final startController = TextEditingController(text: '09:00');
    final endController = TextEditingController(text: '09:45');
    final reasonController = TextEditingController(text: 'Unavailable');
    final blocks = (_dayBookings ?? []).where((booking) {
      final trainerId = booking.trainerId.isNotEmpty
          ? booking.trainerId
          : _normalizeTrainerId(booking.trainer);
      return booking.isBlock && trainerId == selectedTrainerId;
    }).toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Manage $selectedValue availability"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatFullDate(currentDay)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration:
                          const InputDecoration(labelText: 'From (HH:mm)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration:
                          const InputDecoration(labelText: 'Until (HH:mm)'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              if (blocks.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Divider(),
                ...blocks.map(
                  (block) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${block.time}–${block.endTime}'),
                    subtitle: Text(block.bookingName),
                    trailing: IconButton(
                      tooltip: 'Reopen this time',
                      icon: const Icon(Icons.lock_open_rounded),
                      onPressed: () async {
                        try {
                          await BookingApi().unblockTime(block.blockId);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } on BookingCommandException catch (error) {
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await BookingApi().blockTime(
                  trainerId: selectedTrainerId,
                  trainerName: selectedValue,
                  date: currentDay,
                  startTime: startController.text.trim(),
                  endTime: endController.text.trim(),
                  reason: reasonController.text.trim(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } on BookingCommandException catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(error.message)),
                );
              }
            },
            child: const Text('Block time'),
          ),
        ],
      ),
    );
    startController.dispose();
    endController.dispose();
    reasonController.dispose();
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
}
