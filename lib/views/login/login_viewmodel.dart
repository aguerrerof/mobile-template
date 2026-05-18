import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum LoginType { password, code, recover }

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _errorEmail = '';
  String _password = '';
  String _errorPassword = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  LoginType _loginType = LoginType.password;

  String? _errorMessage;
  String? _authCode;
  String? _codeVerifier;
  bool _goToHome = false;

  String get email => _email;
  String get errorEmail => _errorEmail;
  String get password => _password;
  String get errorPassword => _errorPassword;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  LoginType get loginType => _loginType;

  String? get errorMessage => _errorMessage;
  String? get authCode => _authCode;
  bool get goToHome => _goToHome;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _errorEmail = '';
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _errorPassword = '';
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setErrorEmail(String value) {
    _errorEmail = value;
    notifyListeners();
  }

  void setErrorPassword(String value) {
    _errorPassword = value;
    notifyListeners();
  }

  void setLoginType(LoginType value) {
    _loginType = value;
    notifyListeners();
  }

  void cleanErrors() {
    setErrorEmail('');
    setErrorPassword('');
    notifyListeners();
  }

  bool validateStepOne() {
    if (email.isEmpty) {
      _isLoading = false;
      setErrorEmail('Ingresa tu correo electrónico');
      return false;
    } else if (!isValidEmail(email.trim())) {
      _isLoading = false;
      setErrorEmail('Ingresa un correo electrónico válido');
      return false;
    } else {
      return true;
    }
  }

  void setAuthCode(String? code) {
    _authCode = code;
    notifyListeners();
  }

  void setCodeVerifier(String? verifier) {
    _codeVerifier = verifier;
  }

  Future<bool> existEmail() async {
    _isLoading = true;
    cleanErrors();

    try {
      final exist = await ServicesAPI().isEmailRegistered(email);
      return exist;
    } catch (e) {
      print('Error al verificar el email: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // String getUrlPath() {
  //   return ShopifyAuthManager().getCodePath();
  // }

  Future<(bool, String)> sendPasswordResetEmail() async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Correo de recuperación enviado a $email');
      return (true, '');
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.code} - ${e.message}");
      String error = '';
      if (e.code == 'user-not-found') {
        error = 'Usuario no encontrado';
      } else if (e.code == 'too-many-requests') {
        error =
            'Ha realizado demasiados intentos. Por favor, inténtelo más tarde.';
      } else if (e.code == 'invalid-email') {
        error = 'Email inválido';
      } else {
        error = 'Error al enviar el correo: $e';
      }
      return (false, error);
    } catch (e) {
      print('Error al enviar el correo: $e');
      return (false, 'Error al enviar el correo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<(bool, String)> singinWithEmailPassword(bool linkApple) async {
    _isLoading = true;
    cleanErrors();

    if (email.isEmpty) {
      _isLoading = false;
      setErrorEmail('Ingresa tu correo electrónico');
      return (false, '');
    }
    if (password.isEmpty) {
      _isLoading = false;
      setError('Ingresa tu contraseña');
      return (false, 'Ingresa tu contraseña');
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print("Usuario autenticado: ${userCredential.user?.email}");
      if (linkApple) {
        print('vinculando credenciales apple');
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
        await userCredential.user?.linkWithCredential(oauthCredential);
      }

      if (userCredential.user != null) {
        final shopifyCustomerId =
            await ServicesAPI().assignCustomerIdFunction();
        if (shopifyCustomerId != null) {
          await syncLocalCartWithFirestore();
          return (true, '');
        }
      }
      return (
        false,
        'No se pudo ingresar a tu cuenta, por favor intentalo nuevamente.',
      );
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.code} - ${e.message}");
      _isLoading = false;
      String error = '';
      if (e.code == 'user-not-found') {
        // setError('Usuario no encontrado');
        error = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        error = 'Ingresó una contraseña incorrecta o no tiene contraseña ';
      } else if (e.code == 'invalid-email') {
        // setError('Email inválido');
        error = 'Email inválido';
      } else if (e.code == 'invalid-credential') {
        // setError('Contraseña incorrecta');
        error = 'Contraseña incorrecta';
      } else {
        // setError('No posees una cuenta');
        error = 'No posees una cuenta';
      }
      _isLoading = false;
      notifyListeners();
      return (false, error);
    } catch (e) {
      print("Error inesperado: $e");
      _isLoading = false;
      return (false, 'Ha ocurrido un error inesperado');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

