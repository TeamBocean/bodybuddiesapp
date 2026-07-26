import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/pages/credits_page.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/pages/progress_pics_page.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/version_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/authentication.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bbBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Header ──────────────────────────────────────────────
                Text(
                  "SETTINGS",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: bbTextMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Profile ─────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: bbCard,
                        backgroundImage: FirebaseAuth
                                    .instance.currentUser?.photoURL !=
                                null
                            ? NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!)
                            : null,
                        child:
                            FirebaseAuth.instance.currentUser?.photoURL == null
                                ? StreamBuilder<UserModel>(
                                    stream: CloudFirestore().streamUserData(
                                        FirebaseAuth.instance.currentUser!.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data!.name.isNotEmpty) {
                                        return Text(
                                          snapshot.data!.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            color: bbTextSecondary,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        );
                                      }
                                      return Icon(
                                        Icons.person_outline,
                                        size: 28,
                                        color: bbTextMuted,
                                      );
                                    },
                                  )
                                : null,
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<UserModel>(
                        stream: CloudFirestore().streamUserData(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              Text(
                                snapshot.hasData
                                    ? snapshot.data!.name
                                    : "Loading",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: bbText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                FirebaseAuth.instance.currentUser!.email ?? "",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: bbTextSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Info Row — floating text ────────────────────────────
                StreamBuilder<UserModel>(
                  stream: CloudFirestore()
                      .streamUserData(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    final credits =
                        snapshot.hasData ? snapshot.data!.credits : 0;
                    final creditType =
                        snapshot.hasData ? snapshot.data!.creditType : "...";
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CreditsPage()));
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 5),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              creditType.toString().toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: bbTextSecondary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // ── Account ─────────────────────────────────────────────
                _sectionLabel("ACCOUNT"),
                const SizedBox(height: 12),
                _settingsRow(
                  "Profile",
                  "Edit your personal info",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProfilePage()));
                  },
                ),
                _settingsRow(
                  "Training Credits",
                  "Purchase new credits",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CreditsPage()));
                  },
                ),
                _settingsRow(
                  "Progress",
                  "Track your performance",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProgressPicturesPage()));
                  },
                ),
                const SizedBox(height: 32),

                // ── Log Out ─────────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: bbSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            "LOG OUT",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: bbText,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to log out?",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: bbTextSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: bbTextMuted,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Authentication.signOut(context: context);
                              },
                              child: Text(
                                "LOG OUT",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: bbAccentAlt,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      "LOG OUT",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: bbAccentAlt,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        decoration: TextDecoration.underline,
                        decorationColor: bbAccentAlt.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(child: VersionText()),
                SizedBox(height: Dimensions.height10 * 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: bbTextMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 0.25, color: bbBorder.withOpacity(0.5)),
        ),
      ],
    );
  }

  // ── Settings row — no box, just text and divider ──────────────────────────
  Widget _settingsRow(
    String title,
    String subtitle, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: bbText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: bbTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right,
                color: bbTextMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
