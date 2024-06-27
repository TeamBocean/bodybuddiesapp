import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/cloud_firestore.dart';
import '../services/email.dart';
import '../widgets/medium_text_widget.dart';
import 'main_scaffold.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser!.displayName != null) {
      nameController.text =
          FirebaseAuth.instance.currentUser!.displayName.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              message(),
              Column(
                children: [
                  textFormField("Jane Doe", Icons.person, TextInputType.name,
                      nameController),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  textFormField("Weight", Icons.running_with_errors,
                      TextInputType.number, weightController),
                ],
              ),
              SizedBox(
                width: Dimensions.width10 * 20,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.toString().length > 1 &&
                        weightController.text.isNotEmpty) {
                      bool success = CloudFirestore().setUserInfo(
                          nameController.text.toString(),
                          int.parse(weightController.text));
                      if (success) {
                        EmailService().sendPDFToUser(nameController.text.toString());
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MainScaffold(),
                          ),
                        );
                      } else {
                        print("ERROR");
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("All fields must be filled in!")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.width10))),
                  child: MediumTextWidget(
                    text: "Next",
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget textFormField(String hint, IconData iconData,
      TextInputType textInputType, TextEditingController controller) {
    return TextFormField(
      cursorColor: Colors.white,
      controller: controller,
      keyboardType: textInputType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(
          iconData,
          color: Colors.white,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: green,
          ),
        ),
        hintStyle: TextStyle(color: Colors.grey),
        hintText: hint,
      ),
    );
  }

  Widget message() {
    return Column(
      children: [
        MediumTextWidget(
          text: "One last step to get you started!",
          fontSize: Dimensions.fontSize20,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        MediumTextWidget(
          text: "Add your name & weight below",
          fontSize: Dimensions.fontSize16,
          color: Colors.grey,
        ),
      ],
    );
  }
}
