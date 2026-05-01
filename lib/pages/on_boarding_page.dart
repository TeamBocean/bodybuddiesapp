import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/authentication.dart';
import '../services/cloud_firestore.dart';
import '../services/email.dart';
import '../widgets/medium_text_widget.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    final displayName = FirebaseAuth.instance.currentUser?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      nameController.text = displayName.trim();
    }
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                Authentication.signOut(context: context),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Use another account'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              minimumSize: const Size(48, 48),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),
                        message(),
                        SizedBox(height: Dimensions.height35),
                        _textFormField(
                          label: 'Name',
                          hint: 'Jane Doe',
                          iconData: Icons.person,
                          controller: nameController,
                          textInputType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          onFieldSubmitted: (_) =>
                              _weightFocusNode.requestFocus(),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.length < 2) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Dimensions.height15),
                        _textFormField(
                          label: 'Weight (kg)',
                          hint: '75',
                          iconData: Icons.monitor_weight_outlined,
                          controller: weightController,
                          focusNode: _weightFocusNode,
                          textInputType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).unfocus(),
                          validator: (value) {
                            final rawWeight = value?.trim() ?? '';
                            if (rawWeight.isEmpty) {
                              return 'Please enter your weight';
                            }

                            final weight = int.tryParse(rawWeight);
                            if (weight == null || weight <= 0) {
                              return 'Please enter a valid weight';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: Dimensions.height35),
                        _OnboardingButton(
                          formKey: _formKey,
                          nameController: nameController,
                          weightController: weightController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _textFormField({
    required String label,
    required String hint,
    required IconData iconData,
    required TextEditingController controller,
    required TextInputType textInputType,
    required TextInputAction textInputAction,
    required FormFieldValidator<String> validator,
    List<TextInputFormatter>? inputFormatters,
    List<String>? autofillHints,
    FocusNode? focusNode,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color ?? bbTextSecondary;

    return TextFormField(
      cursorColor: theme.colorScheme.primary,
      controller: controller,
      focusNode: focusNode,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          iconData,
          color: secondaryTextColor,
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
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
          color:
              Theme.of(context).textTheme.bodyMedium?.color ?? bbTextSecondary,
        ),
      ],
    );
  }
}

class _OnboardingButton extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController weightController;

  const _OnboardingButton({
    required this.formKey,
    required this.nameController,
    required this.weightController,
  });

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _isCreatingUser = false;

  Future<void> _handleSubmit() async {
    final formState = widget.formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isCreatingUser = true;
    });

    try {
      final name = widget.nameController.text.trim();
      final weight = int.parse(widget.weightController.text.trim());

      final success = await CloudFirestore().setUserInfo(name, weight);

      if (!mounted) return;

      if (success) {
        EmailService().sendPDFToUser(name);
      } else {
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

  void _showRetryDialog() {
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color ?? bbTextSecondary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor:
            theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text(
          'Connection Issue',
          style: theme.dialogTheme.titleTextStyle,
        ),
        content: Text(
          'We had trouble setting up your account. This might be due to a network issue. Would you like to try again?',
          style: theme.dialogTheme.contentTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSubmit();
            },
            child: Text(
              'Try Again',
              style: TextStyle(color: darkGreen),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreatingUser ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          disabledBackgroundColor: darkGrey,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.width10),
          ),
        ),
        child: _isCreatingUser
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : MediumTextWidget(
                text: "Complete setup",
              ),
      ),
    );
  }
}
