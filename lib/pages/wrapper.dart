import 'dart:async';

import 'package:bodybuddiesapp/pages/main_scaffold.dart';
import 'package:bodybuddiesapp/pages/on_boarding_page.dart';
import 'package:bodybuddiesapp/pages/sign_in_page.dart';
import 'package:bodybuddiesapp/utils/dimensions.dart';
import 'package:bodybuddiesapp/utils/profile_completion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({
    Key? key,
    @visibleForTesting this.authStateStream,
    @visibleForTesting this.userDocumentStreamFor,
    @visibleForTesting this.signInBuilder,
    @visibleForTesting this.onboardingBuilder,
    @visibleForTesting this.mainScaffoldBuilder,
  }) : super(key: key);

  @visibleForTesting
  final Stream<User?>? authStateStream;

  @visibleForTesting
  final Stream<DocumentSnapshot<Map<String, dynamic>>> Function(String uid)?
      userDocumentStreamFor;

  @visibleForTesting
  final WidgetBuilder? signInBuilder;

  @visibleForTesting
  final WidgetBuilder? onboardingBuilder;

  @visibleForTesting
  final WidgetBuilder? mainScaffoldBuilder;

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _retryCount = 0;
  late Stream<User?> _authStateStream;
  final Map<String, Stream<DocumentSnapshot<Map<String, dynamic>>>>
      _userDocumentStreams = {};

  @override
  void initState() {
    super.initState();
    _authStateStream =
        widget.authStateStream ?? FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    Dimensions.init(context);

    return StreamBuilder<User?>(
      key: ValueKey('auth-stream-$_retryCount'),
      stream: _authStateStream,
      builder: (context, authSnapshot) {
        if (authSnapshot.hasError) {
          return _AuthErrorScreen(
            message: 'We had trouble checking your sign-in status.',
            onRetry: _retryAuthGate,
          );
        }

        if (authSnapshot.connectionState != ConnectionState.active) {
          return const _AuthLoadingScreen();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return widget.signInBuilder?.call(context) ?? const SignInPage();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey('user-doc-${user.uid}-$_retryCount'),
          stream: _userDocumentStreamFor(user.uid),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.hasError) {
              return _AuthErrorScreen(
                message: 'We had trouble loading your account.',
                onRetry: _retryAuthGate,
              );
            }

            if (!userDocSnapshot.hasData &&
                userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const _AuthLoadingScreen();
            }

            final userData = userDocSnapshot.data?.data();
            if (hasCompletedProfile(userData)) {
              _backfillEmailIfNeeded(user, userData);
              return widget.mainScaffoldBuilder?.call(context) ??
                  const MainScaffold();
            }

            return widget.onboardingBuilder?.call(context) ??
                OnBoardingPage(onContinue: _retryAuthGate);
          },
        );
      },
    );
  }

  void _retryAuthGate() {
    setState(() {
      _retryCount++;
      _authStateStream =
          widget.authStateStream ?? FirebaseAuth.instance.authStateChanges();
      _userDocumentStreams.clear();
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocumentStreamFor(
    String uid,
  ) {
    return _userDocumentStreams.putIfAbsent(
      uid,
      () =>
          widget.userDocumentStreamFor?.call(uid) ??
          FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
    );
  }

  void _backfillEmailIfNeeded(User user, Map<String, dynamic>? data) {
    if (data == null) {
      return;
    }

    final storedEmail = (data['email'] as String?)?.trim() ?? '';
    final authEmail = user.email?.trim().toLowerCase() ?? '';
    final patch = <String, dynamic>{};

    if (storedEmail.isEmpty && authEmail.isNotEmpty) {
      patch["email"] = authEmail;
    }

    if (data['profile_completed'] != true && hasCompletedProfile(data)) {
      patch["profile_completed"] = true;
    }

    if (patch.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(patch, SetOptions(merge: true));
    }
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AuthErrorScreen({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
