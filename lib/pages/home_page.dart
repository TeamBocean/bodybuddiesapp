import 'package:bodybuddiesapp/models/booking.dart';
import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/widgets/booking_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/medium_text_widget.dart';
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
  late Animation<double> _fadeAnimation;
  
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    
    // Initialize role-based access
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
    // Hardcoded version since package_info_plus is removed
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Builder(
            builder: (BuildContext builderContext) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(builderContext).colorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(Dimensions.width10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(Dimensions.width15),
                      decoration: BoxDecoration(
                        color: Theme.of(builderContext).colorScheme.background,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(ASSETS + "logo.png", height: 100,),
                    ),
                    SizedBox(height: Dimensions.height20),
                    MediumTextWidget(
                      text: "What's New in BodyBuddies!",
                      fontSize: Dimensions.fontSize14,
                      color: Theme.of(builderContext).colorScheme.primary,
                    ),
                    SizedBox(height: Dimensions.height20),
                    Container(
                      padding: EdgeInsets.all(Dimensions.width15),
                      decoration: BoxDecoration(
                        color: Theme.of(builderContext).colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _buildWhatsNewItem(
                            context: builderContext,
                            icon: Icons.calendar_today,
                            title: "Improved Booking System",
                            description: "Fixed year handling for all bookings.",
                          ),
                          SizedBox(height: Dimensions.height15),
                          _buildWhatsNewItem(
                            context: builderContext,
                            icon: Icons.notifications,
                            title: "Bug Fixes & Improvements",
                            description: "Credit refunds and cancellation fixes.",
                          ),
                          SizedBox(height: Dimensions.height15),
                          _buildWhatsNewItem(
                            context: builderContext,
                            icon: Icons.speed,
                            title: "New Sessions Page",
                            description: "New page to see your bookings.",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(builderContext).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10 * 3,
                          vertical: Dimensions.height10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: MediumTextWidget(
                        text: "Got it!",
                        color: Colors.white,
                        fontSize: Dimensions.fontSize16,
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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: Dimensions.iconSize16,
          ),
        ),
        SizedBox(width: Dimensions.width15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediumTextWidget(
                text: title,
                fontSize: Dimensions.fontSize14,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              ),
              SizedBox(height: Dimensions.height5),
              MediumTextWidget(
                text: description,
                fontSize: Dimensions.fontSize12,
                color: Colors.grey,
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
    // Use role-based access control
    if (_isEmployee) {
      return FutureBuilder<String>(
        future: getUserName(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, userData) {
          if (userData.hasData) {
            return adminView(userData.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return userView();
    }
  }

  Widget adminView(String name) {
    return StreamBuilder<List<Booking>>(
        stream: CloudFirestore().streamAllBookings(
          currentDate.month, 
          currentDate.day,
          year: currentDate.year, // Pass year parameter
        ),
        builder: (context, snapshot) {
          List<Booking> bookings = [];
          
          if (snapshot.hasData) {
            bookings = List.from(snapshot.data!);
            
            // Filter bookings to only those matching the current date
            bookings.removeWhere((booking) {
              // Use centralized date handling from Booking model
              return !booking.isOnDate(currentDate);
            });
            
            // Apply trainer filter (unless main admin or developer)
            if (_trainerFilter != null) {
              bookings.removeWhere((booking) => 
                booking.trainer.toLowerCase() != _trainerFilter!.toLowerCase()
              );
            }
          }
          
          // Normalize display name
          String displayName = name;
          if (name == "BODY BUDDIES HEALTH & FITNESS") {
            displayName = "Mark";
          }
          
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            userInformationHeader(),
                            Row(
                              children: [
                                // Admin Tools button
                                if (_isMainAdmin || _isDeveloper)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AdminToolsPage(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.settings,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                FirebaseAuth.instance.currentUser!.photoURL != null
                                    ? CircleAvatar(
                                        backgroundColor: Colors.grey.shade400,
                                        radius: Dimensions.width27,
                                        backgroundImage: NetworkImage(
                                          FirebaseAuth.instance.currentUser!
                                              .photoURL as String,
                                        ),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Colors.grey.shade400,
                                        radius: Dimensions.width27,
                                        child: MediumTextWidget(
                                            text: displayName.isNotEmpty 
                                                ? displayName[0].toUpperCase() 
                                                : "M", 
                                            color: Colors.black),
                                      ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Dimensions.height20 / 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MediumTextWidget(
                              text: "Upcoming Sessions",
                              fontSize: Dimensions.fontSize22,
                            ),
                            if (_trainerFilter != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width10,
                                  vertical: Dimensions.height5,
                                ),
                                decoration: BoxDecoration(
                                  color: darkGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _trainerFilter!,
                                  style: TextStyle(
                                    color: darkGreen,
                                    fontSize: Dimensions.fontSize12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate =
                                        currentDate.subtract(Duration(days: 1));
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).iconTheme.color ??
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                )),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentDate = DateTime.now();
                                });
                              },
                              child: MediumTextWidget(
                                text: DateFormat.yMMMEd().format(currentDate),
                                fontSize: Dimensions.fontSize18,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Colors.black,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate =
                                        currentDate.add(Duration(days: 1));
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).iconTheme.color ??
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color ??
                                      Colors.black,
                                )),
                          ],
                        ),
                      ],
                    ),
                    snapshot.hasData
                        ? bookings.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: Dimensions.height35 * 4.5,
                                    bottom: Dimensions.height10 * 6),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: bookings
                                        .map((booking) => GestureDetector(
                                              onDoubleTap: () {
                                                _showUpdateNameDialog(booking);
                                              },
                                              child: BookingWidget(
                                                isBooked: true,
                                                slots: [],
                                                booking: booking,
                                                isAdmin: true,
                                                month: 0,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              )
                            : NoBookingsWidget(
                                message: "No Sessions Today",
                                showSubHeading: false,
                              )
                        : const Center(child: CircularProgressIndicator())
                  ],
                ),
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
          title: const Text('Update Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                String newName = nameController.text;
                CloudFirestore()
                    .updateBookingName(
                      booking.month.toString(),
                      booking.day.toString(),
                      booking.id,
                      newName,
                      year: booking.year, // Pass the booking's actual year
                    )
                    .then((success) {
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name updated successfully')),
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

  Widget userView() {
    return FutureBuilder<UserModel>(
        future: CloudFirestore()
            .getUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          List<Booking> bookings = [];
          
          if (snapshot.hasData) {
            bookings = List.from(snapshot.data!.bookings);
            // Use centralized date handling from Booking model
            bookings.removeWhere((booking) => !booking.isOnDate(currentDate));
          }
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: userInformationHeader(),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // TODO: Navigate to profile
                          },
                          child: Hero(
                            tag: 'profile_avatar',
                            child: FirebaseAuth.instance.currentUser!.photoURL != null
                                ? CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: Dimensions.width27,
                                    backgroundImage: NetworkImage(
                                      FirebaseAuth.instance.currentUser!.photoURL as String,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    radius: Dimensions.width27,
                                    child: MediumTextWidget(
                                        text: snapshot.hasData
                                            ? snapshot.data!.name
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : "",
                                        color: Theme.of(context).colorScheme.primary),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    Align(
                        alignment: Alignment.topLeft,
                        child: MediumTextWidget(
                          text: "Upcoming Bookings",
                          fontSize: Dimensions.fontSize22,
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: Dimensions.height10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  currentDate = currentDate
                                      .subtract(const Duration(days: 1));
                                });
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Theme.of(context).iconTheme.color,
                              )),
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: currentDate,
                                firstDate: DateTime(DateTime.now().year, 1, 1),
                                lastDate: DateTime(DateTime.now().year, 12, 31),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  currentDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width15,
                                vertical: Dimensions.height10,
                              ),
                              decoration: BoxDecoration(
                                color: currentDate.day == DateTime.now().day
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: MediumTextWidget(
                                text: DateFormat.yMMMEd().format(currentDate),
                                fontSize: Dimensions.fontSize16,
                                color: currentDate.day == DateTime.now().day
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  currentDate = currentDate
                                      .add(const Duration(days: 1));
                                });
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).iconTheme.color,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                snapshot.hasData
                    ? bookings.isNotEmpty
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: Dimensions.height35 * 6.5,
                                  bottom: Dimensions.height10 * 6),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: bookings
                                      .map((booking) => BookingWidget(
                                            isBooked: true,
                                            slots: const [],
                                            booking: booking,
                                            isAdmin: false,
                                            month: 0,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                        : snapshot.data!.credits == 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  NoBookingsWidget(
                                    message:
                                        "Oops, you're out of credits. Let's top you up so you can keep training!",
                                    showSubHeading: false,
                                  ),
                                  SizedBox(height: Dimensions.height20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreditsPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Dimensions.width20,
                                        vertical: Dimensions.height10,
                                      ),
                                    ),
                                    child: MediumTextWidget(
                                      text: "Get Credits",
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSize16,
                                    ),
                                  ),
                                ],
                              )
                            : NoBookingsWidget(
                                message:
                                    "Looks like you've got a free day!\nLet's fix that with a session.",
                                showSubHeading: true)
                    : Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
              ],
            ),
          );
        });
  }

  Widget userInformationHeader() {
    return FutureBuilder<UserModel>(
        future: CloudFirestore()
            .getUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediumTextWidget(
                    text: getTodaysDate(),
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                    fontSize: Dimensions.fontSize14),
                SizedBox(height: Dimensions.height5),
                MediumTextWidget(
                  text: "Hi, ${snapshot.data!.name}",
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(height: Dimensions.height10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: Dimensions.iconSize16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: Dimensions.width5),
                      MediumTextWidget(
                        text: "${snapshot.data!.credits} Credits",
                        fontSize: Dimensions.fontSize14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  String getTodaysDate() {
    return "${months[DateTime.now().month - 1]}, ${DateTime.now().day}";
  }

  DateTime getBookingAsDateTime(String time, String date) {
    List<String> dateAsList = date.split("/");
    String day = dateAsList.first.padLeft(2, '0');
    String month = formatMonth(dateAsList[1]);

    int year;
    if (dateAsList.length == 3) {
      // If year is included in the date
      year = int.parse(dateAsList[2]);
    } else {
      // If year is not included, determine based on the current month
      int currentYear = DateTime.now().year;

      // Use current year for future dates, previous year for past dates
      year = currentYear;
    }

    // Ensure the date string is formatted correctly
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
