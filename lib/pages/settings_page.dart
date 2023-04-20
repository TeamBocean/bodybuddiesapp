import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/pages/credits_page.dart';
import 'package:bodybuddiesapp/pages/profile_page.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MediumTextWidget(text: "Profile"),
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
                child: Icon(
                  Icons.person,
                  size: Dimensions.width15 * 3,
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
                      children: [
                        snapshot.hasData
                            ? MediumTextWidget(text: "${snapshot.data!.name}")
                            : MediumTextWidget(text: "Loading"),
                        MediumTextWidget(
                          text: "${FirebaseAuth.instance.currentUser!.email}",
                          color: Colors.grey,
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
                  color: darkGrey,
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
                              Column(
                                children: [
                                  MediumTextWidget(
                                    text: "Subscription",
                                    color: Colors.grey,
                                    fontSize: Dimensions.fontSize11,
                                  ),
                                  MediumTextWidget(
                                    text: snapshot.hasData
                                        ? "${snapshot.data!.creditType}"
                                        : "Loading...",
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSize14,
                                  ),
                                ],
                              ),
                              Container(
                                width: 0.2,
                                height: Dimensions.height10 * 5,
                                color: Colors.white,
                              ),
                              Column(
                                children: [
                                  MediumTextWidget(
                                    text: "Credits",
                                    color: Colors.grey,
                                    fontSize: Dimensions.fontSize11,
                                  ),
                                  MediumTextWidget(
                                    text: snapshot.hasData
                                        ? "${snapshot.data!.credits}"
                                        : "Loading...",
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSize14,
                                  ),
                                ],
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
                  child: settingsOption("Credits", Icons.monetization_on)),
              settingsOption("Progress", Icons.browse_gallery),
              SizedBox(
                height: Dimensions.height10 * 2,
              ),
              SizedBox(
                width: Dimensions.width20 * 5,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimensions.width10),
                            side: BorderSide(color: Colors.white))),
                    onPressed: () => Authentication.signOut(context: context),
                    child: Center(
                      child: MediumTextWidget(
                        text: "Log Out",
                        fontSize: Dimensions.fontSize14,
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget settingsOption(String title, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimensions.height10 * 6,
      child: Card(
        color: darkGrey,
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
                    color: Colors.orange,
                  ),
                  SizedBox(
                    width: Dimensions.width10,
                  ),
                  MediumTextWidget(
                    text: title,
                    color: Colors.white,
                    fontSize: Dimensions.fontSize16,
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Colors.white,
                size: Dimensions.height35,
              )
            ],
          ),
        ),
      ),
    );
  }
}
