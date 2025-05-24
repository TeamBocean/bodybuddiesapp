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
  TextEditingController controller = TextEditingController();
  TextEditingController name = TextEditingController();
  bool _useMetric = true; // true for kg, false for lbs

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
                          SizedBox(height: Dimensions.height20),
                          // Profile Avatar
                          CircleAvatar(
                            radius: Dimensions.width20 * 2,
                            backgroundColor: darkGreen,
                            backgroundImage: FirebaseAuth.instance.currentUser!.photoURL != null
                                ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                                : null,
                            child: FirebaseAuth.instance.currentUser!.photoURL == null
                                ? Text(
                                    snapshot.data!.name.isNotEmpty
                                        ? snapshot.data!.name[0].toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      fontSize: Dimensions.fontSize22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: Dimensions.height20),

                          // Account Information Section
                          _buildSectionHeader("Account Information"),
                          settingsOption(
                            "${snapshot.data!.name}",
                            Icons.person,
                            onTap: () =>
                                _showEditNameDialog(snapshot.data!.name),
                            showEdit: true,
                          ),
                          settingsOption(
                            "${FirebaseAuth.instance.currentUser!.email}",
                            Icons.email,
                            showEdit: false,
                          ),
                          settingsOption(
                            _formatWeight(snapshot.data!.weight),
                            Icons.monitor_weight,
                            onTap: () =>
                                _showEditWeightDialog(snapshot.data!.weight),
                            showEdit: true,
                          ),

                          SizedBox(height: Dimensions.height20),

                          // Actions Section
                          _buildSectionHeader("Actions"),
                          settingsOption(
                            "Delete Account",
                            Icons.delete,
                            onTap: () => _showDeleteAccountDialog(),
                            showEdit: false,
                            isDestructive: true,
                          ),
                          SizedBox(height: Dimensions.height20),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.logout),
                              label: Text("Log Out"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkGrey,
                                padding: EdgeInsets.symmetric(
                                    vertical: Dimensions.height15),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.width10),
                                ),
                              ),
                              onPressed: () =>
                                  Authentication.signOut(context: context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      child: Row(
        children: [
          MediumTextWidget(
            text: title,
            fontSize: Dimensions.fontSize16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  String _formatWeight(int weight) {
    if (_useMetric) {
      return "$weight kg";
    } else {
      return "${(weight * 2.20462).round()} lbs";
    }
  }

  void _showEditNameDialog(String currentName) {
    name.text = currentName;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: background,
        title: Text("Edit Name", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: name,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your name",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.isNotEmpty) {
                CloudFirestore().updateUserName(name.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditWeightDialog(int currentWeight) {
    controller.text = currentWeight.toString();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: background,
        title: Text("Edit Weight", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your weight",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Row(
              children: [
                Text("Unit:", style: TextStyle(color: Colors.white)),
                SizedBox(width: Dimensions.width10),
                ChoiceChip(
                  label: Text("kg"),
                  selected: _useMetric,
                  onSelected: (selected) {
                    setState(() => _useMetric = selected);
                  },
                ),
                SizedBox(width: Dimensions.width10),
                ChoiceChip(
                  label: Text("lbs"),
                  selected: !_useMetric,
                  onSelected: (selected) {
                    setState(() => _useMetric = !selected);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                CloudFirestore().updateUserWeight(int.parse(controller.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: background,
        title: Text("Delete Account", style: TextStyle(color: Colors.red)),
        content: Text(
          "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              CloudFirestore().deleteUser();
              Authentication.signOut(context: context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  Widget settingsOption(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    bool showEdit = true,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimensions.height10 * 6,
      child: Card(
        color: darkGrey,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
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
                      color: isDestructive ? Colors.red : Colors.orange,
                    ),
                    SizedBox(width: Dimensions.width10),
                    MediumTextWidget(
                      text: title,
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: Dimensions.fontSize14,
                      // fontWeight:
                      //     isDestructive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ],
                ),
                if (showEdit)
                  Icon(
                    Icons.edit,
                    color: Colors.grey,
                    size: Dimensions.height20,
                  )
                else if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: Dimensions.height20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
