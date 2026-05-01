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
                      style: GoogleFonts.plusJakartaSans(
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
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height10 + 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Got it",
                          style: GoogleFonts.plusJakartaSans(
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: bbText,
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
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
                                    style: GoogleFonts.plusJakartaSans(
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: bbTextSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Container(height: 0.5, color: bbBorder)),
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
                            style: GoogleFonts.plusJakartaSans(
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
            style: GoogleFonts.plusJakartaSans(
              color: bbText,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter new name",
              hintStyle: GoogleFonts.plusJakartaSans(color: bbTextMuted),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Update',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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
          List<Booking> bookings = [];

          if (snapshot.hasData) {
            bookings = List.from(snapshot.data!.bookings);
            bookings.removeWhere((booking) => !booking.isOnDate(currentDate));
            _sortBookingsByDateTime(bookings);
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: userInformationHeader()),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Hero(
                          tag: 'profile_avatar',
                          child: FirebaseAuth
                                      .instance.currentUser!.photoURL !=
                                  null
                              ? CircleAvatar(
                                  backgroundColor: bbCard,
                                  radius: Dimensions.width27,
                                  backgroundImage: NetworkImage(
                                    FirebaseAuth
                                        .instance.currentUser!.photoURL
                                        as String,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: bbCard,
                                  radius: Dimensions.width27,
                                  child: Text(
                                    snapshot.hasData
                                        ? snapshot.data!.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : "",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: bbText,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),

                  // Section title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "UPCOMING",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: bbTextSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(height: 0.5, color: bbBorder),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),

                  // Date nav
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
                                      child: BookingWidget(
                                        isBooked: true,
                                        slots: const [],
                                        booking: bookings[index],
                                        isAdmin: false,
                                        month: 0,
                                      ),
                                    );
                                  },
                                )
                              : snapshot.data!.credits == 0
                                  ? SingleChildScrollView(
                                      key: const ValueKey('no_credits'),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height:
                                                  Dimensions.height35 * 2),
                                          NoBookingsWidget(
                                            message:
                                                "Your collection is empty.",
                                            showSubHeading: false,
                                          ),
                                          SizedBox(
                                              height: Dimensions.height20),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CreditsPage(),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                                Icons.add_rounded),
                                            label: Text(
                                              "Browse Plans",
                                              style: GoogleFonts
                                                  .plusJakartaSans(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor: bbAccent,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    Dimensions.width20,
                                                vertical:
                                                    Dimensions.height10,
                                              ),
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      key: ValueKey<String>(
                                          'empty_${currentDate.toString()}'),
                                      child: NoBookingsWidget(
                                        message:
                                            "A day for rest.\nYou are clear for today.",
                                        showSubHeading: true,
                                        onViewTomorrow: () {
                                          setState(() {
                                            currentDate = DateTime.now()
                                                .add(const Duration(days: 1));
                                          });
                                        },
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
                  currentDate =
                      currentDate.subtract(const Duration(days: 1));
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.chevron_left_rounded,
                    color: bbAccent, size: 20),
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
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        DateFormat.yMMMEd().format(currentDate),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: _isToday(currentDate) ? bbText : bbTextSecondary,
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
      future: CloudFirestore()
          .getUserData(FirebaseAuth.instance.currentUser!.uid),
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
                style: GoogleFonts.plusJakartaSans(
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
                style: GoogleFonts.plusJakartaSans(
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
                        MaterialPageRoute(builder: (context) => const CreditsPage()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          credits.toString(),
                          style: GoogleFonts.plusJakartaSans(
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
                          style: GoogleFonts.plusJakartaSans(
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
                        style: GoogleFonts.plusJakartaSans(
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
                        style: GoogleFonts.plusJakartaSans(
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
