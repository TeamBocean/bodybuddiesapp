import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:flutter/material.dart';

import '../services/cloud_firestore.dart';
import '../widgets/medium_text_widget.dart';
import 'main_scaffold.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  TextEditingController nameController = TextEditingController();

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
              textFormField("Jane Doe", Icons.person),
              SizedBox(
                width: Dimensions.width10 * 20,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.toString().length > 1) {
                      bool success = CloudFirestore()
                          .setUserInfo(true, nameController.text.toString());
                      if (success) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MainScaffold(),
                          ),
                        );
                      } else {
                        print("ERROR");
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Name field is empty!")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: darkGreen,
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

  Widget textFormField(String hint, IconData iconData) {
    return TextFormField(
      cursorColor: Colors.white,
      controller: nameController,
      keyboardType: TextInputType.name,
      style: TextStyle(
        color: Colors.white
      ),
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
        MediumTextWidget(
          text: "Add your name below",
          fontSize: Dimensions.fontSize16,
        ),
      ],
    );
  }
}
