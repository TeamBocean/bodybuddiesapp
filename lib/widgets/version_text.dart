import 'package:flutter/material.dart';

class VersionText extends StatefulWidget {
  const VersionText({super.key});

  @override
  State<VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: Text(
        "BodyBuddies v1.3.8",
        style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
