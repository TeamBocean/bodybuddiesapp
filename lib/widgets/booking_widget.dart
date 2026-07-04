import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/bookings.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_dialog.dart';
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

  /// When non-null the slot is shown as unavailable with this short reason
  /// (e.g. "Booked today") instead of an actionable Book pill.
  final String? disabledReason;

  const BookingWidget({
    Key? key,
    required this.booking,
    required this.isBooked,
    required this.month,
    required this.isAdmin,
    this.slots = const [],
    this.day = 0,
    this.trainer = "",
    this.disabledReason,
  }) : super(key: key);

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  Bookings? _previousData;

  // Pressed state for the tappable slot (drives the Book pill highlight)
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Bookings>(
      stream: CloudFirestore().streamBookedDates("", year: widget.booking.year),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _previousData = snapshot.data;
          final isBooked = isAlreadyBooked(widget.booking, snapshot.data!.list);
          final isPast = widget.booking.isPast;
          final isDisabled = (isBooked && !widget.isBooked) ||
              isPast ||
              widget.disabledReason != null;
          return _buildBookingCard(context, isDisabled, snapshot.data!.list);
        } else if (_previousData != null) {
          final isBooked = isAlreadyBooked(widget.booking, _previousData!.list);
          final isPast = widget.booking.isPast;
          final isDisabled = (isBooked && !widget.isBooked) ||
              isPast ||
              widget.disabledReason != null;
          return _buildBookingCard(context, isDisabled, _previousData!.list);
        } else {
          return _buildSkeletonCard();
        }
      },
    );
  }

  // ─── Slot Card ───────────────────────────────────────────────────────────
  Widget _buildBookingCard(
      BuildContext context, bool isDisabled, Map bookings) {
    final isAlreadyTaken =
        isAlreadyBooked(widget.booking, bookings) && !widget.isBooked;
    final isPast = widget.booking.isPast;
    final canBook = !widget.isBooked &&
        !isAlreadyTaken &&
        !isPast &&
        widget.disabledReason == null;

    return Semantics(
      button: canBook,
      enabled: canBook,
      label: _semanticLabel(canBook, isAlreadyTaken),
      child: AbsorbPointer(
        absorbing: isDisabled,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Opacity(
            opacity: isDisabled ? 0.4 : 1.0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown:
                  canBook ? (_) => setState(() => _pressed = true) : null,
              onTapUp: canBook ? (_) => setState(() => _pressed = false) : null,
              onTapCancel:
                  canBook ? () => setState(() => _pressed = false) : null,
              onTap: () {
                if (canBook) HapticFeedback.lightImpact();
                _handleTap(context, bookings);
              },
              child: AnimatedScale(
                scale: _pressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildTimeColumn()),
                      _buildRightSide(
                          context, bookings, canBook, isAlreadyTaken),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(bool canBook, bool isAlreadyTaken) {
    if (canBook) return "Book ${widget.booking.time}, 45 minute session";
    if (widget.isBooked) {
      return "${widget.booking.time} session, "
          "${widget.booking.isPast ? 'complete' : 'confirmed'}";
    }
    final reason = widget.disabledReason ?? (isAlreadyTaken ? "taken" : "");
    return "${widget.booking.time} session, $reason";
  }

  Widget _buildTimeColumn() {
    return Column(
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
        if (widget.isBooked && widget.booking.bookingName.isNotEmpty)
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
    } else if (widget.disabledReason != null) {
      return _mutedChip(widget.disabledReason!);
    } else if (isAlreadyTaken) {
      return _mutedChip("Taken");
    } else if (canBook) {
      // Clear, tappable Book pill with a pressed state.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _pressed ? bbAccent.withOpacity(0.75) : bbAccent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          "Book",
          style: GoogleFonts.inter(
            fontSize: 13,
            color: bbOnAccent,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  /// Small muted status chip (e.g. "Taken", "Booked today").
  Widget _mutedChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bbTextMuted.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          color: bbTextMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
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
