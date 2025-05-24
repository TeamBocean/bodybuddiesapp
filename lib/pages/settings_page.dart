import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/pages/credits_page.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/pages/progress_pics_page.dart';
import 'package:bodybuddiesapp/providers/theme_provider.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:bodybuddiesapp/widgets/version_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final labelColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
            child: Column(
              children: [
                SizedBox(height: Dimensions.height20),
                // Profile Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Implement profile picture change
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: Dimensions.width50,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            backgroundImage:
                                FirebaseAuth.instance.currentUser?.photoURL !=
                                        null
                                    ? NetworkImage(FirebaseAuth
                                        .instance.currentUser!.photoURL!)
                                    : null,
                            child: FirebaseAuth
                                        .instance.currentUser?.photoURL ==
                                    null
                                ? StreamBuilder<UserModel>(
                                    stream: CloudFirestore().streamUserData(
                                        FirebaseAuth.instance.currentUser!.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data!.name.isNotEmpty) {
                                        return MediumTextWidget(
                                          text: snapshot.data!.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          fontSize: Dimensions.fontSize32,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        );
                                      }
                                      return Icon(
                                        Icons.person,
                                        size: Dimensions.width15 * 3,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      );
                                    },
                                  )
                                : null,
                          ),
                          // Positioned(
                          //   right: 0,
                          //   bottom: 0,
                          //   child: Container(
                          //     padding: EdgeInsets.all(Dimensions.width5),
                          //     decoration: BoxDecoration(
                          //       color: Theme.of(context).colorScheme.primary,
                          //       shape: BoxShape.circle,
                          //     ),
                          //     child: Icon(
                          //       Icons.edit,
                          //       size: Dimensions.iconSize16,
                          //       color: Theme.of(context).colorScheme.onPrimary,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height15),
                // User Info
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
                                fontSize: Dimensions.fontSize20,
                                color: textColor)
                            : MediumTextWidget(
                                text: "Loading", color: textColor),
                        SizedBox(height: Dimensions.height5),
                        MediumTextWidget(
                          text: "${FirebaseAuth.instance.currentUser!.email}",
                          color: labelColor,
                          fontSize: Dimensions.fontSize14,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: Dimensions.height20),
                // Subscription & Credits Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.card_membership,
                        title: "Subscription",
                        value: (context, snapshot) => snapshot.hasData
                            ? "${snapshot.data!.creditType}"
                            : "Loading...",
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // TODO: Implement subscription upgrade
                        },
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.monetization_on,
                        title: "Credits",
                        value: (context, snapshot) => snapshot.hasData
                            ? "${snapshot.data!.credits}"
                            : "Loading...",
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreditsPage()));
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                // Settings Options
                _buildSettingsSection(
                  title: "Account",
                  options: [
                    SettingsOption(
                      title: "Profile",
                      subtitle: "Edit your personal info",
                      icon: Icons.person,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()));
                      },
                    ),
                    SettingsOption(
                      title: "Training Credits",
                      subtitle: "Purchase new credits.",
                      icon: Icons.monetization_on,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreditsPage()));
                      },
                    ),
                    SettingsOption(
                      title: "Progress",
                      subtitle: "Track your performance",
                      icon: Icons.browse_gallery,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProgressPicturesPage()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                // Appearance Section
                _buildSettingsSection(
                  title: "Appearance",
                  options: [
                    SettingsOption(
                      title: "Dark Mode",
                      subtitle: "Switch between light and dark theme",
                      icon: themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        themeProvider.setThemeMode(
                          themeProvider.isDarkMode
                              ? ThemeMode.light
                              : ThemeMode.dark,
                        );
                      },
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          themeProvider.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding:
                          EdgeInsets.symmetric(vertical: Dimensions.height15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.width10),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Log Out"),
                          content: Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Authentication.signOut(context: context);
                              },
                              child: Text(
                                "Log Out",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: Dimensions.iconSize20),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: Dimensions.fontSize16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                VersionText(),
                // Add extra padding for bottom navigation bar
                SizedBox(height: Dimensions.height10 * 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String Function(BuildContext, AsyncSnapshot<UserModel>) value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: Dimensions.iconSize20,
            ),
            SizedBox(height: Dimensions.height10),
            StreamBuilder<UserModel>(
              stream: CloudFirestore()
                  .streamUserData(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    MediumTextWidget(
                      text: title,
                      fontSize: Dimensions.fontSize12,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: Dimensions.height5),
                    MediumTextWidget(
                      text: value(context, snapshot),
                      fontSize: Dimensions.fontSize16,
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<SettingsOption> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Dimensions.width5),
          child: MediumTextWidget(
            text: title,
            fontSize: Dimensions.fontSize14,
            color: Theme.of(context).textTheme.bodyMedium?.color ??
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        ...options.map((option) => option),
      ],
    );
  }
}

class SettingsOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.width15),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: Dimensions.iconSize20,
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediumTextWidget(
                      text: title,
                      fontSize: Dimensions.fontSize16,
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: Dimensions.height5),
                    MediumTextWidget(
                      text: subtitle,
                      fontSize: Dimensions.fontSize12,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  size: Dimensions.iconSize20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
