import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthProvider { google, apple, password, unknown }

class ChangePasswordViewModel extends ChangeNotifier {
  String _oldPassword = '';
  String _password = '';
  String _confirmPassword = '';
  bool _obscurePassword = true;
  bool _obscureConPassword = true;
  User? _user;
  bool _oldPasswordIsNeeded = true;

  User? get user => _user;
  String get oldPassword => _oldPassword;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfPassword => _obscureConPassword;
  bool get hasMinLength => _password.length >= 8;
  bool get passwordsMatch => _password == _confirmPassword && _password != "";
  bool get oldPasswordIsNeeded => _oldPasswordIsNeeded;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void setOldPassword(String value) {
    _oldPassword = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfPasswordVisibility() {
    _obscureConPassword = !_obscureConPassword;
    notifyListeners();
  }

  Future<void> getProfile() async {
    try {
      _user = FirebaseAuth.instance.currentUser;
      final authProvider = _getAuthProvider(_user);

      if (authProvider == AuthProvider.password) {
        _oldPasswordIsNeeded = true;
      } else {
        _oldPasswordIsNeeded = false;
      }
      notifyListeners();
    } catch (e) {
      print("Error inesperado: $e");
    } finally {}
  }

  Future<void> updatePasswordUser(BuildContext context) async {
    if (_oldPassword == '' && _oldPasswordIsNeeded) {
      if (context.mounted) {
        showCustomFlushbar(context, message: 'Ingrese su contraseña actual');
      }
      return;
    }
    if (!hasMinLength || !passwordsMatch) {
      if (context.mounted) {
        showCustomFlushbar(
          context,
          message: 'Complete los requisitos de la contraseña',
        );
      }
      return;
    }

    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();

    try {
      _user = FirebaseAuth.instance.currentUser;
      final authProvider = _getAuthProvider(_user);

      switch (authProvider) {
        case AuthProvider.google:
          await _reauthenticateWithGoogle();
        case AuthProvider.apple:
          await _reauthenticateWithApple();
        case AuthProvider.password:
          final cred = EmailAuthProvider.credential(
            email: _auth.currentUser!.email!,
            password: _oldPassword,
          );
          await _auth.currentUser!.reauthenticateWithCredential(cred);
        case AuthProvider.unknown:
          throw Exception('Proveedor de autenticación no compatible.');
      }

      await _auth.currentUser!.updatePassword(_password.trim());

      if (context.mounted) {
        Navigator.pop(context);
        showCustomFlushbar(
          context,
          message: 'La contraseña se actualizó correctamente.',
          backgroundColor: MyColors.successAlertColor,
          textColor: MyColors.successAlerttextColor,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        if (context.mounted) {
          showCustomFlushbar(
            context,
            message: 'La contraseña actual es incorrecta.',
          );
        }
        return;
      } else {
        print("Error al reautenticar: ${e.code}");
        if (context.mounted) {
          showCustomFlushbar(
            context,
            message: 'Hubo un error al actualizar su contraseña.',
          );
        }
      }
    } catch (e) {
      print("Error inesperado: $e");
      if (context.mounted) {
        showCustomFlushbar(
          context,
          message: 'Hubo un error al actualizar su contraseña.',
        );
      }
      return;
    } finally {
      loading.hide();
      notifyListeners();
    }
  }

  AuthProvider _getAuthProvider(User? user) {
    final providers = _user?.providerData.map((p) => p.providerId).toList();
    if (providers == null) {
      return AuthProvider.unknown;
    }

    if (providers.contains('password')) {
      return AuthProvider.password;
    }
    if (providers.contains('google.com')) {
      return AuthProvider.google;
    }
    if (providers.contains('apple.com')) {
      return AuthProvider.apple;
    }
    return AuthProvider.unknown;
  }

  // Reautenticar con Google
  Future<void> _reauthenticateWithGoogle() async {
    await GoogleSignIn.instance.initialize();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      return;
    }

    final googleUser = await GoogleSignIn.instance.authenticate(
      scopeHint: ['email', 'profile'],
    );

    final authClient = GoogleSignIn.instance.authorizationClient;
    final authorization = await authClient.authorizationForScopes([
      'email',
      'profile',
    ]);

    final googleAuth = googleUser.authentication;
    if (googleAuth.idToken == null) {
      return;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: authorization?.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
      credential,
    );
  }

  // Reautenticar con Apple
  Future<void> _reauthenticateWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
      oauthCredential,
    );
  }
}

