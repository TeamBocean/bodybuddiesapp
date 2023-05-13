import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageManager {
  static Future<bool> saveImage(List<int> imageBytes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String base64Image = base64Encode(imageBytes);
    List<String> images = prefs.getStringList("images") ?? [];
    images.add(base64Image);
    return prefs.setStringList("images", images);
  }

  static Future<List<Image>> getImage() async {
    List<Image> list = [];
    List<String> imagesAsString = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    imagesAsString = prefs.getStringList("images") ?? [];
    imagesAsString.forEach((element) {
      list.add(Image.memory(base64Decode(element)));
    });
    return list;
  }
}
