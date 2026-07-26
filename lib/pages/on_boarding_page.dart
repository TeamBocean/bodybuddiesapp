import 'package:bodybuddiesapp/utils/colors.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/authentication.dart';
import '../services/cloud_firestore.dart';
import '../widgets/medium_text_widget.dart';

enum WeightUnit { kg, lb }

int? convertWeightToKg(String rawWeight, WeightUnit unit) {
  final value = double.tryParse(rawWeight.trim().replaceAll(',', '.'));
  if (value == null || value <= 0) {
    return null;
  }

  final kilograms = unit == WeightUnit.kg ? value : value * 0.45359237;
  final roundedKilograms = kilograms.round();
  return roundedKilograms > 0 ? roundedKilograms : null;
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({
    Key? key,
    @visibleForTesting this.initialName,
    @visibleForTesting this.submitUserInfo,
    @visibleForTesting this.sendWelcomeEmail,
    this.onContinue,
  }) : super(key: key);

  @visibleForTesting
  final String? initialName;

  @visibleForTesting
  final Future<bool> Function(String name, int weight)? submitUserInfo;

  @visibleForTesting
  final Future<void> Function(String name)? sendWelcomeEmail;

  final VoidCallback? onContinue;

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();
  final GlobalKey<_OnboardingButtonState> _submitButtonKey =
      GlobalKey<_OnboardingButtonState>();
  WeightUnit _weightUnit = WeightUnit.kg;

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
                  _weightUnitSelector(),
                  SizedBox(height: Dimensions.height15),
                  _textFormField(
                    label: 'Weight (${_weightUnitLabel(_weightUnit)})',
                    hint: _weightUnit == WeightUnit.kg ? '75' : '165',
                    iconData: Icons.monitor_weight_outlined,
                    controller: weightController,
                    focusNode: _weightFocusNode,
                    textInputType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                      ),
                    ],
                    onFieldSubmitted: (_) =>
                        _submitButtonKey.currentState?.handleSubmit(),
                    validator: (value) {
                      final rawWeight = value?.trim() ?? '';
                      if (rawWeight.isEmpty) {
                        return 'Please enter your weight';
                      }

                      final parsedWeight = double.tryParse(
                        rawWeight.replaceAll(',', '.'),
                      );
                      if (parsedWeight == null || parsedWeight <= 0) {
                        return 'Enter a number, like 75';
                      }

                      final maxWeight =
                          _weightUnit == WeightUnit.kg ? 500 : 1100;
                      if (parsedWeight > maxWeight) {
                        return 'Enter a weight of $maxWeight ${_weightUnitLabel(_weightUnit)} or less';
                      }

                      if (convertWeightToKg(rawWeight, _weightUnit) == null) {
                        return 'Enter a weight above 0';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: Dimensions.height35),
                  _OnboardingButton(
                    key: _submitButtonKey,
                    formKey: _formKey,
                    nameController: nameController,
                    weightController: weightController,
                    weightUnit: _weightUnit,
                    submitUserInfo: widget.submitUserInfo,
                    sendWelcomeEmail: widget.sendWelcomeEmail,
                    onContinue: widget.onContinue,
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
          text: "Let’s personalize your plan",
          fontSize: Dimensions.fontSize20,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        MediumTextWidget(
          text: "Your weight helps us tailor your training and nutrition.",
          fontSize: Dimensions.fontSize16,
          color:
              Theme.of(context).textTheme.bodyMedium?.color ?? bbTextSecondary,
        ),
      ],
    );
  }

  Widget _weightUnitSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight unit',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color ?? bbTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        Row(
          children: [
            Expanded(child: _weightUnitChip(WeightUnit.kg, 'kg')),
            SizedBox(width: Dimensions.width10),
            Expanded(child: _weightUnitChip(WeightUnit.lb, 'lb')),
          ],
        ),
        SizedBox(height: Dimensions.height10),
        Text(
          'Choose the unit you use; we’ll convert it for your profile.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color ?? bbTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _weightUnitChip(WeightUnit unit, String label) {
    final theme = Theme.of(context);
    final isSelected = _weightUnit == unit;

    return SizedBox(
      width: double.infinity,
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => _changeWeightUnit(unit),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.outline),
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _changeWeightUnit(WeightUnit nextUnit) {
    if (_weightUnit == nextUnit) {
      return;
    }

    final currentValue = double.tryParse(
      weightController.text.trim().replaceAll(',', '.'),
    );
    if (currentValue != null && currentValue > 0) {
      final kilograms = _weightUnit == WeightUnit.kg
          ? currentValue
          : currentValue * 0.45359237;
      final convertedValue =
          nextUnit == WeightUnit.kg ? kilograms : kilograms / 0.45359237;
      final formattedValue = _formatWeight(convertedValue);
      weightController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }

    setState(() {
      _weightUnit = nextUnit;
    });
  }
}

String _weightUnitLabel(WeightUnit unit) => unit == WeightUnit.kg ? 'kg' : 'lb';

String _formatWeight(double value) {
  final roundedToOneDecimal = (value * 10).round() / 10;
  if (roundedToOneDecimal == roundedToOneDecimal.roundToDouble()) {
    return roundedToOneDecimal.toInt().toString();
  }
  return roundedToOneDecimal.toStringAsFixed(1);
}

class _OnboardingButton extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController weightController;
  final WeightUnit weightUnit;
  final Future<bool> Function(String name, int weight)? submitUserInfo;
  final Future<void> Function(String name)? sendWelcomeEmail;
  final VoidCallback? onContinue;

  const _OnboardingButton({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.weightController,
    required this.weightUnit,
    this.submitUserInfo,
    this.sendWelcomeEmail,
    this.onContinue,
  }) : super(key: key);

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  bool _isCreatingUser = false;
  bool _setupSucceeded = false;

  Future<void> handleSubmit() async {
    FocusScope.of(context).unfocus();

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
      final weight = convertWeightToKg(
        widget.weightController.text,
        widget.weightUnit,
      );
      if (weight == null) {
        _showRetryDialog();
        return;
      }

      succeeded = widget.submitUserInfo != null
          ? await widget.submitUserInfo!(name, weight)
          : await CloudFirestore().setUserInfo(name, weight);

      if (!mounted) return;

      if (succeeded) {
        setState(() {
          _setupSucceeded = true;
        });
        if (widget.sendWelcomeEmail != null) {
          _sendWelcomeEmailInBackground(name);
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

  void _sendWelcomeEmailInBackground(String name) {
    Future<void>(() async {
      try {
        if (widget.sendWelcomeEmail != null) {
          await widget.sendWelcomeEmail!(name);
        }
      } catch (e) {
        debugPrint('Welcome email failed (non-blocking): $e');
      }
    });
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
          'Setup not finished',
          style: theme.dialogTheme.titleTextStyle,
        ),
        content: Text(
          'We couldn’t save your profile. Check your connection and try again. Your entries are still here.',
          style: theme.dialogTheme.contentTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              handleSubmit();
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
                    'Your details are still here. Check your connection, then '
                    'tap Complete setup to try again.',
                  ),
                ),
              );
            },
            child: Text(
              'Keep editing',
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
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: Dimensions.height15),
          MediumTextWidget(
            text: "Your profile is saved.",
            fontSize: Dimensions.fontSize16,
            color: bbTextSecondary,
          ),
          SizedBox(height: Dimensions.height15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onContinue ??
                  () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Your profile is saved. Tap Continue when the app is ready.',
                          ),
                        ),
                      ),
              child: const Text('Continue'),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreatingUser ? null : handleSubmit,
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
