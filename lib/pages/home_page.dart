import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/no_bookings_widget.dart';
import 'credits_page.dart';
import 'admin_page/admin_tools_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  DateTime currentDate = DateTime.now();
  late AnimationController _animationController;

  // Role-based access control
  late bool _isEmployee;
  late bool _isDeveloper;
  late bool _isMainAdmin;
  String? _trainerFilter;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();

    final cloudFirestore = CloudFirestore();
    _isEmployee = cloudFirestore.isEmployee();
    _isDeveloper = cloudFirestore.isDeveloper();
    _isMainAdmin = cloudFirestore.isMainAdmin();
    _trainerFilter = cloudFirestore.getEmployeeTrainerName();

    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVersion = prefs.getString('last_app_version');
    const currentVersion = "1.3.8";

    if (lastVersion != currentVersion) {
      if (mounted) {
        _showWhatsNewModal();
        await prefs.setString('last_app_version', currentVersion);
      }
    }
  }

  void _showWhatsNewModal() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Builder(
            builder: (BuildContext builderContext) {
              return Container(
                decoration: BoxDecoration(
                  color: bbSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(Dimensions.width10 + 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(Dimensions.width15),
                      child: Image.asset(
                        ASSETS + "logo.png",
                        height: 64,
                      ),
                    ),
                    SizedBox(height: Dimensions.height15),
                    Text(
                      "What's new",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        color: bbText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    Container(
                      padding: EdgeInsets.all(Dimensions.width15),
                      decoration: BoxDecoration(
                        color: bbCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildWhatsNewItem(
                            context: builderContext,
                            icon: Icons.calendar_today,
                            title: "Improved Booking System",
                            description:
                                "Fixed year handling for all bookings.",
                          ),
                          SizedBox(height: Dimensions.height15),
                          _buildWhatsNewItem(
                            context: builderContext,
                            icon: Icons.notifications_none,
                            title: "Bug Fixes & Improvements",
                            description:
                                "Credit refunds and cancellation fixes.",
                          ),
                          SizedBox(height: Dimensions.height15),
                          _buildWhatsNewItem(
                            context: builderContext,
                            icon: Icons.view_agenda_outlined,
                            title: "New Sessions Page",
                            description: "New page to see your bookings.",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bbAccent,
                          foregroundColor: bbOnAccent,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height10 + 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Got it",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWhatsNewItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.width10),
          decoration: BoxDecoration(
            color: bbAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: bbAccent,
            size: Dimensions.iconSize16,
          ),
        ),
        SizedBox(width: Dimensions.width15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: bbText,
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: bbTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> getUserName(String userId) async {
    UserModel userModel = await CloudFirestore().getUserData(userId);
    return userModel.name;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmployee) {
      return FutureBuilder<String>(
        future: getUserName(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, userData) {
          if (userData.hasData) {
            return adminView(userData.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(color: bbAccent),
            );
          }
        },
      );
    } else {
      return userView();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADMIN VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget adminView(String name) {
    return StreamBuilder<List<Booking>>(
        stream: CloudFirestore().streamAllBookings(
          currentDate.month,
          currentDate.day,
          year: currentDate.year,
        ),
        builder: (context, snapshot) {
          List<Booking> bookings = [];

          if (snapshot.hasData) {
            bookings = List.from(snapshot.data!);
            bookings.removeWhere((booking) {
              return !booking.isOnDate(currentDate);
            });
            if (_trainerFilter != null) {
              bookings.removeWhere((booking) =>
                  booking.trainer.toLowerCase() !=
                  _trainerFilter!.toLowerCase());
            }
            _sortBookingsByDateTime(bookings);
          }

          String displayName = name;
          if (name == "BODY BUDDIES HEALTH & FITNESS") {
            displayName = "Mark";
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: userInformationHeader()),
                      Row(
                        children: [
                          if (_isMainAdmin || _isDeveloper)
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminToolsPage(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.settings_outlined,
                                color: bbTextSecondary,
                              ),
                            ),
                          FirebaseAuth.instance.currentUser!.photoURL != null
                              ? CircleAvatar(
                                  backgroundColor: bbCard,
                                  radius: Dimensions.width27,
                                  backgroundImage: NetworkImage(
                                    FirebaseAuth.instance.currentUser!.photoURL
                                        as String,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: bbCard,
                                  radius: Dimensions.width27,
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : "M",
                                    style: GoogleFonts.inter(
                                      color: bbText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),

                  // Section title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "SESSIONS",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: bbTextSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 0.5, color: bbBorder)),
                    ],
                  ),
                  SizedBox(height: Dimensions.height5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_trainerFilter != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            color: bbAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _trainerFilter!,
                            style: GoogleFonts.inter(
                              color: bbAccent,
                              fontSize: Dimensions.fontSize12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),

                  // Date nav bar
                  _buildDateNavBar(),
                  SizedBox(height: Dimensions.height15),

                  // Bookings list
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: !snapshot.hasData
                          ? Center(
                              key: const ValueKey('loading'),
                              child: CircularProgressIndicator(
                                color: bbAccent,
                              ),
                            )
                          : bookings.isNotEmpty
                              ? ListView.builder(
                                  key: ValueKey<String>(
                                      'bookings_${currentDate.toString()}'),
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(
                                      bottom: Dimensions.height10 * 8),
                                  itemCount: bookings.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: Dimensions.height10),
                                      child: GestureDetector(
                                        onDoubleTap: () {
                                          _showUpdateNameDialog(
                                              bookings[index]);
                                        },
                                        child: BookingWidget(
                                          isBooked: true,
                                          slots: const [],
                                          booking: bookings[index],
                                          isAdmin: true,
                                          month: 0,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : SingleChildScrollView(
                                  key: ValueKey<String>(
                                      'empty_${currentDate.toString()}'),
                                  child: NoBookingsWidget(
                                    message: "No sessions today.",
                                    showSubHeading: false,
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showUpdateNameDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          backgroundColor: bbSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Update Name',
            style: GoogleFonts.inter(
              color: bbText,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter new name",
              hintStyle: GoogleFonts.inter(color: bbTextMuted),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Update',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onPressed: () {
                String newName = nameController.text;
                CloudFirestore()
                    .updateBookingName(
                  booking.month.toString(),
                  booking.day.toString(),
                  booking.id,
                  newName,
                  year: booking.year,
                )
                    .then((success) {
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Name updated successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update name')),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget userView() {
    return StreamBuilder<UserModel>(
        stream: CloudFirestore()
            .streamUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: bbAccent),
              ),
            );
          }

          final user = snapshot.data!;
          final dayBookings = List<Booking>.from(user.bookings)
            ..removeWhere((booking) => !booking.isOnDate(currentDate));
          _sortBookingsByDateTime(dayBookings);

          final upcomingCount =
              user.bookings.where((booking) => booking.isUpcoming).length;
          final completedThisWeek = user.bookings.where((booking) {
            return booking.isPast && _isInSameWeek(booking.getDateOnly());
          }).length;

          return SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: SingleChildScrollView(
                key: ValueKey<String>('home_${currentDate.toIso8601String()}'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 132),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHomeHeader(user),
                    const SizedBox(height: 18),
                    _buildCreditBalanceCard(user.credits),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildHomeStatCard(
                            icon: Icons.event_available_outlined,
                            iconColor: bbWarning,
                            value: upcomingCount.toString(),
                            label: "Upcoming sessions",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHomeStatCard(
                            icon: Icons.done_all_rounded,
                            iconColor: bbSuccess,
                            value: completedThisWeek.toString(),
                            label: "Completed this week",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    _buildWeekSectionHeader(),
                    const SizedBox(height: 12),
                    _buildWeekStrip(user.bookings),
                    const SizedBox(height: 34),
                    _buildSessionsHeader(dayBookings.length),
                    const SizedBox(height: 10),
                    _buildHomeSessions(dayBookings, user),
                    const SizedBox(height: 16),
                    _buildStreakCard(user.bookings),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildHomeHeader(UserModel user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreetingWord().replaceAll(',', ''),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: bbTextSecondary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _firstName(user.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  color: bbText,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        _buildRoundIconButton(Icons.notifications_none_rounded),
        const SizedBox(width: 12),
        Hero(
          tag: 'profile_avatar',
          child: _buildUserAvatar(user, radius: 24),
        ),
      ],
    );
  }

  Widget _buildRoundIconButton(IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: HapticFeedback.lightImpact,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bbSurface,
            shape: BoxShape.circle,
            border: Border.all(color: bbBorder, width: 1),
          ),
          child: Icon(icon, color: bbTextSecondary, size: 21),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user, {required double radius}) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    final initial = _firstName(user.name).isNotEmpty
        ? _firstName(user.name)[0].toUpperCase()
        : "B";

    return CircleAvatar(
      radius: radius,
      backgroundColor: bbAccent,
      child: CircleAvatar(
        radius: radius - 2,
        backgroundColor: bbCard,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? Text(
                initial,
                style: GoogleFonts.inter(
                  color: bbText,
                  fontWeight: FontWeight.w700,
                  fontSize: radius * 0.72,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCreditBalanceCard(int credits) {
    const creditGoal = 12;
    final progress = (credits / creditGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 20, 20),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CREDIT BALANCE",
                  style: GoogleFonts.inter(
                    color: bbTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      credits.toString(),
                      style: GoogleFonts.inter(
                        color: bbText,
                        fontSize: 48,
                        height: 0.9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        credits == 1 ? "credit left" : "credits left",
                        style: GoogleFonts.inter(
                          color: bbTextSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreditsPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View plans",
                        style: GoogleFonts.inter(
                          color: bbAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: bbAccent,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 98,
            height: 98,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    backgroundColor: bbAccent.withOpacity(0.16),
                    valueColor: const AlwaysStoppedAnimation<Color>(bbAccent),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${(progress * 100).round()}%",
                      style: GoogleFonts.inter(
                        color: bbText,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "of $creditGoal",
                      style: GoogleFonts.inter(
                        color: bbTextSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      height: 94,
      padding: const EdgeInsets.fromLTRB(18, 20, 16, 18),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 18),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: bbText,
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: bbTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "This Week",
            style: GoogleFonts.inter(
              color: bbText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          _formatWeekRange(currentDate),
          style: GoogleFonts.inter(
            color: bbTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekStrip(List<Booking> bookings) {
    final start = _startOfWeek(currentDate);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: List.generate(7, (index) {
          final day = start.add(Duration(days: index));
          final isSelected = day.year == currentDate.year &&
              day.month == currentDate.month &&
              day.day == currentDate.day;
          final hasBooking = bookings.any((booking) => booking.isOnDate(day));

          return Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 9),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => currentDate = day);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 53,
                height: 85,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? bbAccent : bbCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? bbAccent : bbBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE').format(day).toUpperCase(),
                      style: GoogleFonts.inter(
                        color: isSelected ? bbOnAccent : bbTextSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      day.day.toString(),
                      style: GoogleFonts.inter(
                        color: isSelected ? bbOnAccent : bbText,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: isSelected || hasBooking ? 6 : 0,
                      height: isSelected || hasBooking ? 6 : 0,
                      decoration: BoxDecoration(
                        color: isSelected ? bbOnAccent : bbAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSessionsHeader(int count) {
    return Row(
      children: [
        Text(
          _sessionsHeaderTitle(),
          style: GoogleFonts.inter(
            color: bbText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: bbAccent,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.inter(
                color: bbOnAccent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHomeSessions(List<Booking> bookings, UserModel user) {
    if (bookings.isEmpty) {
      return _buildEmptySessionsCard(user.credits);
    }

    return Column(
      children: [
        _buildPrimarySessionCard(bookings.first),
        for (int i = 1; i < bookings.length; i++) ...[
          const SizedBox(height: 12),
          _buildCompactSessionCard(bookings[i]),
        ],
      ],
    );
  }

  Widget _buildPrimarySessionCard(Booking booking) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTrainingBackdrop(booking),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildCoachAvatar(booking, 23),
                    const SizedBox(width: 13),
                    Expanded(
                      child: _buildSessionText(booking, compact: false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: booking.isPast
                        ? null
                        : () => _showCancelBookingDialog(booking),
                    icon: Icon(
                      booking.isPast
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      size: 17,
                    ),
                    label:
                        Text(booking.isPast ? "Completed" : "Cancel session"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: booking.isPast
                          ? bbCard
                          : bbAccentAlt.withOpacity(0.12),
                      foregroundColor:
                          booking.isPast ? bbTextSecondary : bbAccentAlt,
                      disabledBackgroundColor: bbCard,
                      disabledForegroundColor: bbTextSecondary,
                      elevation: 0,
                      textStyle: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingBackdrop(Booking booking) {
    return SizedBox(
      height: 104,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5D453C),
                  Color(0xFF252A32),
                  Color(0xFF101216),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.62),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 18,
            child: Icon(
              Icons.fitness_center_rounded,
              color: Colors.white.withOpacity(0.18),
              size: 76,
            ),
          ),
          Positioned(
            left: 22,
            top: 27,
            child: Text(
              _formatSessionTime(booking),
              style: GoogleFonts.inter(
                color: bbText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSessionCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbBorder, width: 1),
      ),
      child: Row(
        children: [
          _buildCoachAvatar(booking, 23),
          const SizedBox(width: 13),
          Expanded(child: _buildSessionText(booking, compact: true)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap:
                booking.isPast ? null : () => _showCancelBookingDialog(booking),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: booking.isPast ? bbCard : bbAccentAlt.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: booking.isPast
                    ? null
                    : Border.all(color: bbAccentAlt.withOpacity(0.24)),
              ),
              child: Text(
                booking.isPast ? "Done" : "Cancel",
                style: GoogleFonts.inter(
                  color: booking.isPast ? bbTextSecondary : bbAccentAlt,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAvatar(Booking booking, double radius) {
    final initial =
        booking.trainer.isNotEmpty ? booking.trainer[0].toUpperCase() : "B";

    return CircleAvatar(
      radius: radius,
      backgroundColor: bbBorder,
      child: CircleAvatar(
        radius: radius - 2,
        backgroundColor: bbCard,
        child: Text(
          initial,
          style: GoogleFonts.inter(
            color: bbAccent,
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionText(
    Booking booking, {
    required bool compact,
  }) {
    final subtitle = compact
        ? "${_formatSessionTime(booking)} · ${_coachLabel(booking)} · 45 min"
        : "${_coachLabel(booking)} · 45 min";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sessionTitle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: bbText,
            fontSize: compact ? 17 : 18,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: bbTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  String _sessionsHeaderTitle() {
    if (_isToday(currentDate)) {
      return "Today's Sessions";
    }

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (currentDate.year == tomorrow.year &&
        currentDate.month == tomorrow.month &&
        currentDate.day == tomorrow.day) {
      return "Tomorrow's Sessions";
    }

    return "${DateFormat('EEE, d MMM').format(currentDate)} Sessions";
  }

  Widget _buildEmptySessionsCard(int credits) {
    final outOfCredits = credits == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            outOfCredits
                ? Icons.account_balance_wallet_outlined
                : Icons.self_improvement_rounded,
            color: bbAccent,
            size: 28,
          ),
          const SizedBox(height: 16),
          Text(
            outOfCredits ? "You're out of credits" : "A day for rest",
            style: GoogleFonts.inter(
              color: bbText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            outOfCredits
                ? "Top up your balance to book your next session."
                : "You are clear today. Keep tomorrow in view.",
            style: GoogleFonts.inter(
              color: bbTextSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (outOfCredits) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreditsPage(),
                  ),
                );
              } else {
                setState(() {
                  currentDate = currentDate.add(const Duration(days: 1));
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: bbAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                outOfCredits ? "View plans" : "View tomorrow",
                style: GoogleFonts.inter(
                  color: bbOnAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(Booking booking) {
    final isWithin24Hours = booking.isWithin24Hours;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                      const Icon(
                        Icons.info_outline,
                        color: bbAccentAlt,
                        size: 18,
                      ),
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
                      onTap: () => Navigator.pop(dialogContext, 'dialog'),
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
                          booking,
                          FirebaseAuth.instance.currentUser!.uid,
                        );
                        Navigator.pop(dialogContext, 'dialog');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Session cancelled")),
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

  Widget _buildStreakCard(List<Booking> bookings) {
    final streak = _currentBookingStreak(bookings);
    final completedThisWeek = bookings.where((booking) {
      return booking.isPast && _isInSameWeek(booking.getDateOnly());
    }).length;
    final displayStreak = streak > 0 ? streak : completedThisWeek;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
      decoration: BoxDecoration(
        color: bbBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bbText.withOpacity(0.78), width: 1),
      ),
      child: Row(
        children: [
          const Text("🔥", style: TextStyle(fontSize: 26)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayStreak > 0
                      ? "$displayStreak-day streak"
                      : "Start a streak",
                  style: GoogleFonts.inter(
                    color: bbText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayStreak > 0
                      ? "Keep it going - book tomorrow!"
                      : "Book your next session to get moving.",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: bbTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: bbTextSecondary,
            size: 24,
          ),
        ],
      ),
    );
  }

  String _firstName(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? "Buddy" : trimmed.split(RegExp(r'\s+')).first;
  }

  String _formatSessionTime(Booking booking) {
    try {
      return DateFormat.jm().format(booking.getDateTime());
    } catch (_) {
      return booking.time;
    }
  }

  String _sessionTitle() {
    return "Training session";
  }

  String _coachLabel(Booking booking) {
    final trainer = booking.trainer.trim();
    return trainer.isEmpty ? "Coach BodyBuddies" : "Coach $trainer";
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  bool _isInSameWeek(DateTime date) {
    final start = _startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(start) && normalized.isBefore(end);
  }

  String _formatWeekRange(DateTime date) {
    final start = _startOfWeek(date);
    final end = start.add(const Duration(days: 6));
    if (start.month == end.month) {
      return "${DateFormat('MMMM d').format(start)} - ${end.day}";
    }
    return "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}";
  }

  int _currentBookingStreak(List<Booking> bookings) {
    final completedDays =
        bookings.where((booking) => booking.isPast).map((booking) {
      final date = booking.getDateOnly();
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    if (completedDays.isEmpty) return 0;

    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!completedDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── Date Navigation Bar ───────────────────────────────────────────────────
  Widget _buildDateNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: bbSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bbBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous day
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  currentDate = currentDate.subtract(const Duration(days: 1));
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child:
                    Icon(Icons.chevron_left_rounded, color: bbAccent, size: 20),
              ),
            ),
          ),
          // Date display
          Expanded(
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: DateTime(DateTime.now().year - 1, 1, 1),
                  lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                );
                if (pickedDate != null) {
                  setState(() {
                    currentDate = pickedDate;
                  });
                }
              },
              onDoubleTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  currentDate = DateTime.now();
                });
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<DateTime>(currentDate),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isToday(currentDate)) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: bbAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Today",
                            style: GoogleFonts.inter(
                              color: bbOnAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        DateFormat.yMMMEd().format(currentDate),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color:
                              _isToday(currentDate) ? bbText : bbTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Next day
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  currentDate = currentDate.add(const Duration(days: 1));
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.chevron_right_rounded,
                    color: bbAccent, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

// ─── Editorial Greeting Header ─────────────────────────────────────────────
  Widget userInformationHeader() {
    return FutureBuilder<UserModel>(
      future:
          CloudFirestore().getUserData(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final firstName = snapshot.data!.name.split(' ').first;
          final credits = snapshot.data!.credits;
          final upcomingCount =
              snapshot.data!.bookings.where((b) => b.isUpcoming).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date label
              Text(
                "${months[DateTime.now().month - 1].toUpperCase()}  •  "
                "${daysOfWeek[DateTime.now().weekday - 1].toUpperCase()}",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: bbTextMuted,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // Greeting — a polite nod, not a greeting card
              Text(
                "${_getGreetingWord()} $firstName.",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: bbText,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              // Credits + Upcoming — floating text, no boxes
              Row(
                children: [
                  // Credits
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreditsPage()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          credits.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            color: bbText,
                            fontWeight: FontWeight.w300,
                            height: 1.0,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "CREDITS",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: bbTextMuted,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Upcoming
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        upcomingCount.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          color: bbText,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "UPCOMING",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: bbTextMuted,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else {
          return SizedBox(
            height: 110,
            child: Center(
              child: CircularProgressIndicator(
                color: bbAccent,
                strokeWidth: 1.5,
              ),
            ),
          );
        }
      },
    );
  }

  String _getGreetingWord() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Good evening,";
  }

  String getTodaysDate() {
    return "${months[DateTime.now().month - 1]}, ${DateTime.now().day}";
  }

  void _sortBookingsByDateTime(List<Booking> bookings) {
    bookings.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
  }

  DateTime getBookingAsDateTime(String time, String date) {
    List<String> dateAsList = date.split("/");
    String day = dateAsList.first.padLeft(2, '0');
    String month = formatMonth(dateAsList[1]);

    int year;
    if (dateAsList.length == 3) {
      year = int.parse(dateAsList[2]);
    } else {
      int currentYear = DateTime.now().year;
      year = currentYear;
    }

    String formattedDate = "$year-$month-$day $time:00";
    DateTime dateTime = DateTime.parse(formattedDate);
    return dateTime;
  }

  String formatMonth(String month) {
    return month.length > 1 ? month : "0${month}";
  }

  bool isBookingComplete(Booking booking) {
    return DateTime.now()
        .isAfter(getBookingAsDateTime(booking.time, booking.date));
  }
}
