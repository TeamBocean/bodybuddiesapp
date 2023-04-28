import 'package:bodybuddiesapp/models/user.dart';
import 'package:bodybuddiesapp/services/cloud_firestore.dart';
import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: MediumTextWidget(
          text: "Account Details",
        ),
      ),
      body: StreamBuilder<UserModel?>(
          stream: CloudFirestore()
              .streamUserData(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: Dimensions.height10 * 2,
                          ),
                          settingsOption(
                              "${snapshot.data!.name}", Icons.person),
                          settingsOption(
                              "${FirebaseAuth.instance.currentUser!.email}",
                              Icons.email),
                          settingsOption("${snapshot.data!.weight}kg",
                              Icons.monetization_on),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        backgroundColor: background,
                                        content: SizedBox(
                                          height: Dimensions.height10 * 12,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MediumTextWidget(
                                                  text:
                                                      "Are you sure you want to delete your account?"),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        CloudFirestore().deleteUser();
                                                        Authentication.signOut(context: context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              primary:
                                                                  Colors.red),
                                                      child: Text("Yes")),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              primary:
                                                                  darkGrey),
                                                      child: Text("No")),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                            },
                            child:
                                settingsOption("Delete account", Icons.delete),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: Dimensions.width20 * 5,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: background,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.width10),
                                        side: BorderSide(color: Colors.white))),
                                onPressed: () =>
                                    Authentication.signOut(context: context),
                                child: Center(
                                  child: MediumTextWidget(
                                    text: "Log Out",
                                    fontSize: Dimensions.fontSize14,
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: Dimensions.height10 * 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return MediumTextWidget(text: "Loading");
            }
          }),
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
                    fontSize: Dimensions.fontSize14,
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
