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
    "Home",
    "Book",
    "Sessions",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bbSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bbBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (i) => Expanded(
              child: _buildNavItem(i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = widget.currentIndex == index;

    return Semantics(
      button: true,
      selected: isActive,
      label: _labels[index],
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTabTapped(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? _activeIcons[index] : _icons[index],
                  key: ValueKey<bool>(isActive),
                  color: isActive ? bbAccent : bbTextMuted,
                  size: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _labels[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isActive ? bbAccent : bbTextMuted,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1 : 0,
                child: Container(
                  width: 18,
                  height: 2,
                  decoration: BoxDecoration(
                    color: bbAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
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
