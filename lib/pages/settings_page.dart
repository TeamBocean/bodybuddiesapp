import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/pages/credits_page.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/pages/progress_pics_page.dart';
import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/authentication.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final labelColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MediumTextWidget(text: "Profile", color: textColor),
                    // Icon(
                    //   Icons.notification_add,
                    //   color: Colors.yellow,
                    // )
                  ],
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                CircleAvatar(
                  radius: Dimensions.width50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: Dimensions.width15 * 3,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                StreamBuilder<UserModel>(
                    stream: CloudFirestore()
                        .streamUserData(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          snapshot.hasData
                              ? MediumTextWidget(
                                  text: "${snapshot.data!.name}",
                                  color: textColor)
                              : MediumTextWidget(
                                  text: "Loading", color: textColor),
                          MediumTextWidget(
                            text: "${FirebaseAuth.instance.currentUser!.email}",
                            color: labelColor,
                            fontSize: Dimensions.fontSize11,
                          ),
                        ],
                      );
                    }),
                SizedBox(
                  height: Dimensions.height10,
                ),
                SizedBox(
                  width: Dimensions.width20 * 10,
                  height: Dimensions.height10 * 6,
                  child: Card(
                    color: Theme.of(context).cardTheme.color,
                    elevation: 0,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: Dimensions.height10),
                      child: StreamBuilder<UserModel>(
                          stream: CloudFirestore().streamUserData(
                              FirebaseAuth.instance.currentUser!.uid),
                          builder: (context, snapshot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MediumTextWidget(
                                        text: "Subscription: ",
                                        color: labelColor,
                                        fontSize: Dimensions.fontSize11,
                                      ),
                                      MediumTextWidget(
                                        text: snapshot.hasData
                                            ? "${snapshot.data!.creditType}"
                                            : "Loading...",
                                        color: textColor,
                                        fontSize: Dimensions.fontSize14,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 0.2,
                                  height: Dimensions.height10 * 4,
                                  color: textColor,
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MediumTextWidget(
                                        text: "Credits: ",
                                        color: labelColor,
                                        fontSize: Dimensions.fontSize11,
                                      ),
                                      MediumTextWidget(
                                        text: snapshot.hasData
                                            ? "${snapshot.data!.credits}"
                                            : "Loading...",
                                        color: textColor,
                                        fontSize: Dimensions.fontSize14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ProfilePage()));
                    },
                    child: settingsOption("Profile", Icons.person)),
                // settingsOption("Notification", Icons.notifications),
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CreditsPage()));
                    },
                    child: settingsOption(
                        "Training Credits", Icons.monetization_on)),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProgressPicturesPage()));
                    },
                    child: settingsOption("Progress", Icons.browse_gallery)),
                GestureDetector(
                    onTap: () {
                      themeProvider.setThemeMode(
                        themeProvider.isDarkMode
                            ? ThemeMode.light
                            : ThemeMode.dark,
                      );
                    },
                    child: settingsOption(
                      themeProvider.isDarkMode ? "Light Mode" : "Dark Mode",
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    )),
                SizedBox(
                  height: Dimensions.height10 * 2,
                ),
                SizedBox(
                  width: Dimensions.width20 * 5,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.width10),
                              side: BorderSide(color: Theme.of(context).colorScheme.onPrimary))),
                      onPressed: () => Authentication.signOut(context: context),
                      child: Center(
                        child: MediumTextWidget(
                          text: "Log Out",
                          fontSize: Dimensions.fontSize14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )),
                ),
                SizedBox(height: Dimensions.height20), // Add bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsOption(String title, IconData icon) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final iconColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimensions.height10 * 6,
      child: Card(
        color: Theme.of(context).cardTheme.color,
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                  ),
                  SizedBox(
                    width: Dimensions.width10,
                  ),
                  MediumTextWidget(
                    text: title,
                    color: textColor,
                    fontSize: Dimensions.fontSize16,
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                color: textColor,
                size: Dimensions.height35,
              )
            ],
          ),
        ),
      ),
    );
  }
}
