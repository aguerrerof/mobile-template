import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashViewModel extends ChangeNotifier {
  String _targetPath = '/home';
  bool _goToTarget = false;

  String get targetPath => _targetPath;
  bool get goToTarget => _goToTarget;

  void setTarget(String newValue) {
    _targetPath = newValue;
    notifyListeners();
  }

  void setGoToTarget(bool newValue) {
    _goToTarget = newValue;
    notifyListeners();
  }

  Future<User?> _resolveCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    try {
      return await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return FirebaseAuth.instance.currentUser;
    }
  }

  Future<void> checkLoginStatus() async {
    final currentUser = await _resolveCurrentUser();
    if (currentUser != null) {
      if (currentUser.emailVerified) {
        setTarget('/home');
      } else {
        setTarget('/verifyEmail');
      }
      setGoToTarget(true);
    } else {
      Timer(const Duration(seconds: 3), () {
        setTarget('/welcome');
        setGoToTarget(true);
      });
    }
  }
}
