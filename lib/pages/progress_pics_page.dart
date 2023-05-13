import 'dart:typed_data';

import 'package:bodybuddiesapp/utils/colors.dart';
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
        child: FutureBuilder<List<Image>>(
            future: ImageManager.getImage(),
            builder: (context, snapshot) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: snapshot.hasData
                      ? snapshot.data!
                          .map(
                            (e) => SafeArea(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  child: e,
                                  width: 200,
                                  height: 250,
                                ),
                              ),
                            ),
                          )
                          .toList()
                      : [],
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
