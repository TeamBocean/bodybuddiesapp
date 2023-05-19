import 'dart:convert';
import 'dart:typed_data';

import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/utils/image_manager.dart';
import 'package:bodybuddiesapp/widgets/medium_text_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPicturesPage extends StatefulWidget {
  const ProgressPicturesPage({Key? key}) : super(key: key);

  @override
  State<ProgressPicturesPage> createState() => _ProgressPicturesPageState();
}

class _ProgressPicturesPageState extends State<ProgressPicturesPage> {
  XFile? image;

  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: MediumTextWidget(
          text: 'My Progress',
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<List<String>>(
            future: ImageManager.getImage(),
            builder: (context, snapshot) {
              return Padding(
                padding: EdgeInsets.only(top: Dimensions.height25),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: snapshot.hasData
                          ? snapshot.data!
                              .map(
                                (image) => Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          ImageManager.deleteImage(image);
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        )),
                                    SafeArea(
                                      child: SizedBox(
                                        width: Dimensions.width20 * 10 +
                                            Dimensions.width50,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.width20),
                                          child: Card(
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.width20)),
                                            child: Image.memory(
                                                base64Decode(image)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList()
                          : [],
                    ),
                  ),
                ),
              );
            }),
      ),
      backgroundColor: background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkGreen,
        child: Icon(Icons.add),
        onPressed: () {
          getImage(ImageSource.gallery);
        },
      ),
    );
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
    Uint8List data = await img!.readAsBytes();

    await ImageManager.saveImage(data.toList()).then((value) => print(value));
  }
}
