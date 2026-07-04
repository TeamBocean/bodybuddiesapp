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
  const OnBoardingPage({
    Key? key,
    @visibleForTesting this.initialName,
    @visibleForTesting this.submitUserInfo,
    @visibleForTesting this.sendWelcomeEmail,
  }) : super(key: key);

  @visibleForTesting
  final String? initialName;

  @visibleForTesting
  final Future<bool> Function(String name, int weight)? submitUserInfo;

  @visibleForTesting
  final Future<void> Function(String name)? sendWelcomeEmail;

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      nameController.text = widget.initialName!;
      return;
    }

    final displayName = FirebaseAuth.instance.currentUser?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      nameController.text = displayName.trim();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    _nameFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: EdgeInsets.fromLTRB(
            Dimensions.width20,
            Dimensions.height20,
            Dimensions.width20,
            Dimensions.height20 + bottomInset,
          ),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Authentication.signOut(context: context),
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
                    focusNode: _nameFocusNode,
                    textInputType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    onFieldSubmitted: (_) => _weightFocusNode.requestFocus(),
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
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                    submitUserInfo: widget.submitUserInfo,
                    sendWelcomeEmail: widget.sendWelcomeEmail,
                  ),
                ],
              ),
            ),
          ),
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
      scrollPadding: const EdgeInsets.only(bottom: 120),
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
  final Future<bool> Function(String name, int weight)? submitUserInfo;
  final Future<void> Function(String name)? sendWelcomeEmail;

  const _OnboardingButton({
    required this.formKey,
    required this.nameController,
    required this.weightController,
    this.submitUserInfo,
    this.sendWelcomeEmail,
  });

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _isCreatingUser = false;
  bool _setupSucceeded = false;

  Future<void> _handleSubmit() async {
    final formState = widget.formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isCreatingUser = true;
      _setupSucceeded = false;
    });

    var succeeded = false;
    try {
      final name = widget.nameController.text.trim();
      final weight = int.parse(widget.weightController.text.trim());

      succeeded = widget.submitUserInfo != null
          ? await widget.submitUserInfo!(name, weight)
          : await CloudFirestore().setUserInfo(name, weight);

      if (!mounted) return;

      if (succeeded) {
        setState(() {
          _setupSucceeded = true;
        });
        try {
          if (widget.sendWelcomeEmail != null) {
            await widget.sendWelcomeEmail!(name);
          } else {
            await EmailService().sendPDFToUser(name);
          }
        } catch (e) {
          debugPrint('Welcome email failed (non-blocking): $e');
        }
      } else {
        _showRetryDialog();
      }
    } catch (e) {
      debugPrint('Unexpected error in onboarding: $e');
      if (mounted) {
        _showRetryDialog();
      }
    } finally {
      if (mounted && !succeeded) {
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
      builder: (dialogContext) => AlertDialog(
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
              Navigator.pop(dialogContext);
              _handleSubmit();
            },
            child: Text(
              'Try Again',
              style: TextStyle(color: darkGreen),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Setup was not completed. Tap Complete setup to try again, '
                    'or use another account to sign out.',
                  ),
                ),
              );
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
    if (_setupSucceeded) {
      return Column(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(darkGreen),
            ),
          ),
          SizedBox(height: Dimensions.height15),
          MediumTextWidget(
            text: "You're all set! Opening the app…",
            fontSize: Dimensions.fontSize16,
            color: bbTextSecondary,
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreatingUser ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          disabledBackgroundColor: darkGreen.withOpacity(0.5),
          foregroundColor: bbOnAccent,
          disabledForegroundColor: bbOnAccent.withOpacity(0.6),
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
                  valueColor: AlwaysStoppedAnimation<Color>(bbOnAccent),
                ),
              )
            : MediumTextWidget(
                text: "Complete setup",
                color: bbOnAccent,
              ),
      ),
    );
  }
}
