import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  int currentIndex;
  PageController? controller;

  BottomNavBar({required this.currentIndex, required this.controller});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.fitness_center_outlined,
    Icons.settings_outlined,
  ];

  static const List<IconData> _activeIcons = [
    Icons.home,
    Icons.calendar_month,
    Icons.fitness_center,
    Icons.settings,
  ];

  static const List<String> _labels = [
    "Agenda",
    "Book",
    "Sessions",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bbBackground,
        border: const Border(
          top: BorderSide(color: bbBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) => _buildNavItem(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTabTapped(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? _activeIcons[index] : _icons[index],
                key: ValueKey<bool>(isActive),
                color: isActive ? bbAccent : bbTextMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[index],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isActive ? bbAccent : bbTextMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
            // Active dot indicator
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: bbAccent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    if (mounted) {
      setState(() {
        widget.currentIndex = index;
        widget.controller!.jumpToPage(index);
      });
    }
  }
}
