import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/dimensions.dart';
import '../widgets/medium_text_widget.dart';

class NutritionPage extends StatelessWidget {
  String title;

  NutritionPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        title: MediumTextWidget(text: "Nutrition"),
      ),
      backgroundColor: background,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                left: Dimensions.width15,
                right: Dimensions.width15,
                top: Dimensions.height15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumTextWidget(
                    text: "Nutrition",
                    fontSize: Dimensions.fontSize22,
                  ),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: darkGrey,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MediumTextWidget(
                              text: title,
                            ),
                            SizedBox(
                              height: Dimensions.height15,
                            ),
                            Text(
                              nutrientTypesMap[title]!,
                              style: TextStyle(
                                fontSize: Dimensions.fontSize16,
                                color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
