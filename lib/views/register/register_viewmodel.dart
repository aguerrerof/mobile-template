import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

enum RegisterType { password, code }

class RegisterViewModel extends ChangeNotifier {
  String _email = '';
  String _errorEmail = '';
  String _name = '';
  String _firstname = '';
  String _errorName = '';
  String _errorFirstname = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConPassword = true;
  RegisterType _registerType = RegisterType.password;

  String get name => _name;
  String get firstname => _firstname;
  String get errorFirstname => _errorFirstname;
  String get errorName => _errorName;
  String get email => _email;
  String get errorEmail => _errorEmail;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfPassword => _obscureConPassword;
  bool get hasMinLength => _password.length >= 8;
  bool get passwordsMatch => _password == _confirmPassword && _password != "";
  RegisterType get registerType => _registerType;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void setName(String value) {
    _name = value;
    _errorName = '';
    notifyListeners();
  }

  void setFirstName(String value) {
    _firstname = value;
    _errorFirstname = '';
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _errorEmail = '';
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

  void selectRegisterType(RegisterType type) {
    _registerType = type;
    notifyListeners();
  }

  void toggleConfPasswordVisibility() {
    _obscureConPassword = !_obscureConPassword;
    notifyListeners();
  }

  void setErrorName(String value) {
    _errorName = value;
    notifyListeners();
  }

  void setErrorfirstName(String value) {
    _errorFirstname = value;
    notifyListeners();
  }

  void setErrorEmail(String value) {
    _errorEmail = value;
    notifyListeners();
  }

  void cleanErrors() {
    _errorName = '';
    _errorEmail = '';
    notifyListeners();
  }

  void refreshPasswords() {
    _password = '';
    _confirmPassword = '';
    notifyListeners();
  }

  bool verifyStepOne() {
    if (name.trim().isEmpty) {
      setErrorName("Ingrese su Nombre");
      return false;
    }

    if (firstname.trim().isEmpty) {
      setErrorfirstName("Ingrese su Apellido");
      return false;
    }

    return true;
  }

  Future<(bool, String, bool)> registerUser(BuildContext context) async {
    _isLoading = true;
    cleanErrors();
    notifyListeners();

    if (name.trim().isEmpty) {
      _isLoading = false;
      setErrorName("Ingrese su nombre y apellido");
      return (false, '', false);
    }
    if (email.trim().isEmpty) {
      _isLoading = false;
      setErrorEmail("Ingresa tu email");
      return (false, '', false);
    }
    if (!hasMinLength || !passwordsMatch) {
      _isLoading = false;
      return (false, 'Complete los requisitos de la contraseña', false);
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await sendEmailVerification();

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user?.reload();
        User? user = _auth.currentUser;

        final result = await ServicesAPI().verifyAndCreateCustomer(null);
        if (result.success) {
          return (true, '', false);
        } else {
          if (result.data?.canReactivate ?? false) {
            final message =
                result.getError() ?? 'Cuenta eliminada, ¿Deseas recuperarla?';
            return (false, message, true);
          }
          if (user != null) {
            await user.delete();
          }
          final message =
              result.getError() ?? 'Existió un error al registrar el usuario';
          return (false, message, false);
        }
      } else {
        return (false, 'Existió un error al registrar el usuario', false);
      }
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.code} - ${e.message}");
      String errorMessage = 'Ha ocurrido un error inesperado';
      if (e.code == 'email-already-in-use') {
        setErrorEmail("El correo ya se encuentra en uso");
      } else if (e.code == 'weak-password') {
        errorMessage = 'Contraseña muy débil';
      } else if (e.code == 'invalid-email') {
        setErrorEmail("Email tiene un formato inválido");
      } else {
        errorMessage = e.message.toString();
      }
      return (false, errorMessage, false);
    } catch (e) {
      print("Error inesperado: $e");
      return (false, 'Ha ocurrido un error inesperado', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showSuccessDialog(BuildContext context) {
    if (!context.mounted) return;

    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text("Login Exitoso"),
            content: const Text("Bienvenido a la app."),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}

