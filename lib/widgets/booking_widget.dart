import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/services/booking_api.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_dialog.dart';
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
  // Pressed state for the tappable slot (drives the Book pill highlight)
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.booking.isPast || widget.disabledReason != null;
    return _buildBookingCard(context, isDisabled);
  }

  // ─── Slot Card ───────────────────────────────────────────────────────────
  Widget _buildBookingCard(BuildContext context, bool isDisabled) {
    const isAlreadyTaken = false;
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: canBook ? (_) => setState(() => _pressed = true) : null,
            onTapUp: canBook ? (_) => setState(() => _pressed = false) : null,
            onTapCancel:
                canBook ? () => setState(() => _pressed = false) : null,
            onTap: () {
              if (canBook) HapticFeedback.lightImpact();
              _handleTap(context);
            },
            child: AnimatedScale(
              scale: _pressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _pressed ? bbCard.withOpacity(0.78) : bbCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: canBook ? bbAccent.withOpacity(0.26) : bbBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildTimeColumn()),
                    _buildRightSide(context, canBook, isAlreadyTaken),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(bool canBook, bool isAlreadyTaken) {
    if (canBook) return "Reserve ${widget.booking.time}, 45 minute session";
    if (widget.isBooked) {
      return "${widget.booking.time} session, "
          "${widget.booking.isPast ? 'complete' : 'confirmed'}";
    }
    final reason = widget.disabledReason ?? (isAlreadyTaken ? "taken" : "");
    return "${widget.booking.time} session, $reason";
  }

  Widget _buildTimeColumn() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: widget.isBooked
                ? bbAccent.withOpacity(0.12)
                : bbSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: bbBorder, width: 1),
          ),
          child: Icon(
            widget.isBooked
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded,
            color: widget.isBooked ? bbAccent : bbTextSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.booking.time,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  color: widget.isBooked ? bbAccent : bbText,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.isBooked ? "Session" : "45 min training session",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: bbTextMuted,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildRightSide(
      BuildContext context, bool canBook, bool isAlreadyTaken) {
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
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () => _showCancelBookingDialog(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: bbAccentAlt,
                  decoration: TextDecoration.underline,
                  decorationColor: bbAccentAlt,
                ),
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _pressed ? bbAccent.withOpacity(0.75) : bbAccent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reserve",
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: bbOnAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.arrow_forward_rounded,
              color: bbOnAccent,
              size: 14,
            ),
          ],
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

  // ─── Thin separator between slots ──────────────────────────────────────────
  // Used by the parent to render between slots

  // ─── Business Logic ────────────────────────────────────────────────────────
  void _handleTap(BuildContext context) {
    if (widget.isBooked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Booked")));
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
                      onTap: () async {
                        try {
                          await BookingApi().cancelSession(
                            booking: widget.booking,
                            userId: widget.booking.userId.isEmpty
                                ? null
                                : widget.booking.userId,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context, 'dialog');
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Session cancelled"),
                            ),
                          );
                        } on BookingCommandException catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        }
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
    if (month < 1 || month > 12) {
      throw RangeError("Invalid month index: $month");
    }
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
