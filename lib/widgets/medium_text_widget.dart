import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MediumTextWidget extends StatefulWidget {
  String text;
  double fontSize;
  Color color;

  MediumTextWidget({required this.text, fontSize, this.color = Colors.white})
      : this.fontSize = fontSize ?? Dimensions.fontSize20;

  @override
  State<MediumTextWidget> createState() => _MediumTextWidgetState();
}

class _MediumTextWidgetState extends State<MediumTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: widget.fontSize,
        color: widget.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
