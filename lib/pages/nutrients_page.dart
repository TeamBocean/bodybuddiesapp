import 'package:bodybuddiesapp/pages/nutrition_page.dart';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class NutrientsPage extends StatelessWidget {
  const NutrientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: Dimensions.width15, right: Dimensions.width15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediumTextWidget(text: "Nutrition"),
              SizedBox(
                height: Dimensions.height10,
              ),
              Row(
                children: [
                  Icon(Icons.info, color: Colors.white,),
                  SizedBox(
                    width: Dimensions.width15,
                  ),
                  MediumTextWidget(
                    text:
                        "All medical information is based on the\nresearch of Mark for reference please visit\nbodybuddiesgym.ie",
                    fontSize: Dimensions.fontSize14,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(
                height: Dimensions.height20,
              ),
              Column(
                children: nutrientAssets
                    .map((asset) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => NutritionPage(
                                      title: nutrientTypes[
                                          nutrientAssets.indexOf(asset)]))),
                          child: nutritionWidget(
                              asset,
                              nutrientTypes[nutrientAssets.indexOf(asset)],
                              context),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nutritionWidget(String asset, String title, BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimensions.height25 * 4,
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.width15)),
            color: darkGrey,
            child: Row(
              children: [
                SizedBox(
                  width: Dimensions.width15,
                ),
                Image.asset(
                  ASSETS + asset,
                  height: Dimensions.height25 * 2,
                ),
                SizedBox(
                  width: Dimensions.width15,
                ),
                MediumTextWidget(
                  text: title,
                  fontSize: Dimensions.fontSize16,
                )
              ],
            )));
  }
}
