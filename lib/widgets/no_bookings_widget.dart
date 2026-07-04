import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class NoBookingsWidget extends StatelessWidget {
  final String message;
  final bool showSubHeading;
  final VoidCallback? onViewTomorrow;
  final VoidCallback? onExploreSchedule;

  const NoBookingsWidget({
    Key? key,
    required this.message,
    required this.showSubHeading,
    this.onViewTomorrow,
    this.onExploreSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // ─── Understated message ─────────────────────────────────────
          Text(
            message.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: bbTextMuted,
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 28),

          // ─── Thin editorial divider ──────────────────────────────────
          Container(
            width: 40,
            height: 0.5,
            color: bbBorder,
          ),

          const SizedBox(height: 28),

          // ─── Navigation Links (All Caps / Wide Spaced / Upright) ─────
          if (showSubHeading)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onViewTomorrow != null)
                    GestureDetector(
                      onTap: onViewTomorrow,
                      child: Text(
                        "V I E W  T O M O R R O W",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: bbTextSecondary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: bbTextMuted,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  if (onViewTomorrow != null && onExploreSchedule != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: bbTextMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (onExploreSchedule != null)
                    GestureDetector(
                      onTap: onExploreSchedule,
                      child: Text(
                        "V I E W  S C H E D U L E",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: bbTextSecondary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: bbTextMuted,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (showSubHeading &&
              onViewTomorrow == null &&
              onExploreSchedule == null)
            Text(
              "V I E W  S C H E D U L E",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: bbTextMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
            ),
        ],
      ),
    );
  }
}
