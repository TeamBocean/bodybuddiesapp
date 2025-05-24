import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatefulWidget {
  const VersionText({super.key});

  @override
  State<VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  PackageInfo? packageInfo;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPackageInfo();
  }

  Future<void> loadPackageInfo() async {
    try {
      var result = await PackageInfo.fromPlatform();
      setState(() {
        packageInfo = result;
      });
    } catch (e) {
      print("Error loading package info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: Text(
        "BodyBuddies v${packageInfo?.version ?? "N/A"} [${packageInfo?.buildNumber ?? "N/A"}]",
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
