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
              _OnboardingButton(
                nameController: nameController,
                weightController: weightController,
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

/// Stateful button widget to handle async user creation
class _OnboardingButton extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController weightController;

  const _OnboardingButton({
    required this.nameController,
    required this.weightController,
  });

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _isCreatingUser = false;

  Future<void> _handleSubmit() async {
    // Validate inputs
    if (widget.nameController.text.trim().length < 2) {
      _showError("Please enter your name (at least 2 characters)");
      return;
    }

    if (widget.weightController.text.isEmpty) {
      _showError("Please enter your weight");
      return;
    }

    final weight = int.tryParse(widget.weightController.text);
    if (weight == null || weight <= 0) {
      _showError("Please enter a valid weight");
      return;
    }

    // Start creating user
    setState(() {
      _isCreatingUser = true;
    });

    try {
      final name = widget.nameController.text.trim();
      
      print('Starting user creation for: $name');
      
      // Create user document in Firestore
      final success = await CloudFirestore().setUserInfo(name, weight);

      if (!mounted) return;

      if (success) {
        // Send welcome email (don't wait for it)
        EmailService().sendPDFToUser(name);

        // Navigate to main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScaffold(),
          ),
        );
      } else {
        // Show error with retry option
        _showRetryDialog();
      }
    } catch (e) {
      print('Unexpected error in onboarding: $e');
      if (mounted) {
        _showRetryDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingUser = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: darkGrey,
        title: const Text(
          'Connection Issue',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'We had trouble setting up your account. This might be due to a network issue. Would you like to try again?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _handleSubmit(); // Retry
            },
            child: Text(
              'Try Again',
              style: TextStyle(color: darkGreen),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // User can stay on onboarding and try again later
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.width10 * 20,
      child: ElevatedButton(
        onPressed: _isCreatingUser ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          disabledBackgroundColor: darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.width10),
          ),
        ),
        child: _isCreatingUser
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : MediumTextWidget(
                text: "Next",
              ),
      ),
    );
  }
}

