import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/bookings.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_dialog.dart';
import 'package:bodybuddiesapp/widgets/stamp_seal_painter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingWidget extends StatefulWidget {
  final Booking booking;
  final bool isBooked;
  final bool isAdmin;
  final int month;
  final int day;
  final List<Widget> slots;
  final String trainer;

  const BookingWidget({
    Key? key,
    required this.booking,
    required this.isBooked,
    required this.month,
    required this.slots,
    required this.isAdmin,
    this.day = 0,
    this.trainer = "",
  }) : super(key: key);

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget>
    with SingleTickerProviderStateMixin {
  Bookings? _previousData;

  // Press-and-hold stamp animation
  late AnimationController _stampController;
  late Animation<double> _stampAnimation;
  bool _isHolding = false;
  bool _stampComplete = false;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _stampAnimation = CurvedAnimation(
      parent: _stampController,
      curve: Curves.easeOutCubic,
    );
    _stampController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isHolding) {
        setState(() => _stampComplete = true);
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Bookings>(
      stream: CloudFirestore().streamBookedDates("", year: widget.booking.year),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _previousData = snapshot.data;
          final isBooked = isAlreadyBooked(widget.booking, snapshot.data!.list);
          final isPast = widget.booking.isPast;
          final isDisabled = (isBooked && !widget.isBooked) || isPast;
          return _buildBookingCard(context, isDisabled, snapshot.data!.list);
        } else if (_previousData != null) {
          final isBooked = isAlreadyBooked(widget.booking, _previousData!.list);
          final isPast = widget.booking.isPast;
          final isDisabled = (isBooked && !widget.isBooked) || isPast;
          return _buildBookingCard(context, isDisabled, _previousData!.list);
        } else {
          return _buildSkeletonCard();
        }
      },
    );
  }

  // ─── "Aperture" Slot Card ───────────────────────────────────────────────────
  Widget _buildBookingCard(
      BuildContext context, bool isDisabled, Map bookings) {
    final isAlreadyTaken =
        isAlreadyBooked(widget.booking, bookings) && !widget.isBooked;
    final isPast = widget.booking.isPast;
    final canBook = !widget.isBooked && !isAlreadyTaken && !isPast;

    return AbsorbPointer(
      absorbing: isDisabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // ─── Press-and-hold to book (Stamp Gesture) ─────────────────
            onLongPressStart: canBook
                ? (_) {
                    setState(() {
                      _isHolding = true;
                      _stampComplete = false;
                    });
                    _stampController.forward(from: 0);
                    HapticFeedback.lightImpact();
                  }
                : null,
            onLongPressEnd: canBook
                ? (_) {
                    setState(() => _isHolding = false);
                    if (_stampComplete) {
                      // Stamp completed — trigger booking
                      _handleBookingAction(context, bookings);
                    } else {
                      // Released too early — reverse
                      _stampController.reverse();
                    }
                  }
                : null,
            onTap: () => _handleTap(context, bookings),
            child: AnimatedBuilder(
              animation: _stampAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // ─── Floating Time Card ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Large floating time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.booking.time,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    color: widget.isBooked ? bbAccent : bbText,
                                    fontWeight: FontWeight.w300,
                                    height: 1.0,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                if (!widget.isBooked)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "45 MIN",
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: bbTextMuted,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                // Booking name (admin / user booked view)
                                if (widget.isBooked &&
                                    widget.booking.bookingName.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      widget.booking.bookingName,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: bbTextSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Right side: status / stamp / action
                          _buildRightSide(
                              context, bookings, canBook, isAlreadyTaken),
                        ],
                      ),
                    ),

                    // ─── Stamp Overlay (fades in on long-press) ──────────
                    if (canBook && _stampAnimation.value > 0)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: _stampAnimation.value * 0.6,
                            child: Transform.scale(
                              scale: 0.5 + (_stampAnimation.value * 0.5),
                              child: Transform.rotate(
                                angle: (-0.15) * (1 - _stampAnimation.value),
                                child: StampSeal(
                                  size: 80,
                                  progress: _stampAnimation.value,
                                  color: bbAccent,
                                  isFilled: _stampComplete,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightSide(
      BuildContext context, Map bookings, bool canBook, bool isAlreadyTaken) {
    if (widget.isBooked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Date
          Text(
            _formatDate(widget.booking),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: bbTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.booking.isPast
                  ? bbTextMuted.withOpacity(0.06)
                  : bbAccent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.booking.isPast ? "Complete" : "Confirmed",
              style: GoogleFonts.inter(
                fontSize: 10,
                color: widget.booking.isPast ? bbTextMuted : bbAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Cancel
          GestureDetector(
            onTap: () => _showCancelBookingDialog(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: bbAccentAlt,
                decoration: TextDecoration.underline,
                decorationColor: bbAccentAlt.withOpacity(0.5),
              ),
            ),
          ),
        ],
      );
    } else if (isAlreadyTaken) {
      return Text(
        "TAKEN",
        style: GoogleFonts.inter(
          fontSize: 10,
          color: bbTextMuted,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
        ),
      );
    } else if (canBook) {
      return Text(
        "AVAILABLE",
        style: GoogleFonts.inter(
          fontSize: 9,
          color: bbAccent.withOpacity(0.6),
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      );
    }
    return const SizedBox();
  }

  // ─── Skeleton ───────────────────────────────────────────────────────────────
  Widget _buildSkeletonCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonBar(width: 80, height: 28),
              const SizedBox(height: 8),
              _skeletonBar(width: 100, height: 14),
            ],
          ),
          const Spacer(),
          _skeletonBar(width: 50, height: 24),
        ],
      ),
    );
  }

  Widget _skeletonBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bbCard,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ─── Thin separator between slots ──────────────────────────────────────────
  // Used by the parent to render between slots

  // ─── Business Logic (unchanged) ────────────────────────────────────────────
  void _handleTap(BuildContext context, Map bookings) {
    if (widget.isBooked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Booked")));
    } else if (isAlreadyBooked(widget.booking, bookings)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Not Available")));
    } else {
      // Tap also opens the dialog as a fallback
      bookingDialog(
        context,
        widget.booking,
        widget.booking.month,
        widget.booking.day,
        widget.trainer.isNotEmpty ? widget.trainer : widget.booking.trainer,
      );
    }
  }

  void _handleBookingAction(BuildContext context, Map bookings) {
    bookingDialog(
      context,
      widget.booking,
      widget.booking.month,
      widget.booking.day,
      widget.trainer.isNotEmpty ? widget.trainer : widget.booking.trainer,
    );
  }

  void _showCancelBookingDialog(BuildContext context) {
    final isWithin24Hours = widget.booking.isWithin24Hours;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bbSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: bbBorder.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cancel this\nsession?",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  color: bbText,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you'd like to cancel?",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: bbTextSecondary,
                ),
              ),
              if (isWithin24Hours) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bbAccentAlt.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bbAccentAlt.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: bbAccentAlt, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Cancelling within 24 hours will not refund your credit.",
                          style: GoogleFonts.inter(
                            color: bbAccentAlt,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, 'dialog'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: bbCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Keep it",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: bbText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        CloudFirestore().removeUserBooking(
                          widget.booking,
                          FirebaseAuth.instance.currentUser!.uid,
                        );
                        Navigator.pop(context, 'dialog');
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Session cancelled"),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: bbAccentAlt.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: bbAccentAlt.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: bbAccentAlt,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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

  bool isAlreadyBooked(Booking booking, Map bookings) {
    String month = booking.month.toString();
    String day = booking.day.toString();
    List<dynamic>? bookedTimes = bookings[month]?[day];
    return bookedTimes != null && bookedTimes.contains(booking.time);
  }

  String _formatDate(Booking booking) {
    int day = booking.day;
    int month = booking.month;
    String suffix = _getDaySuffix(day);
    return '$day$suffix ${_getMonthName(month)}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    if (month < 1 || month > 12)
      throw RangeError("Invalid month index: $month");
    return monthNames[month - 1];
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
