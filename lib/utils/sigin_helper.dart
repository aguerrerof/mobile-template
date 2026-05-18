import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:mobile_app_template/utils/session_helper.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/login/login_screen_step_one.dart';
import 'package:mobile_app_template/components/page_sheet/account_conflict_page_sheet.dart';
import 'package:mobile_app_template/views/splash/splash_screen.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<(bool, String, bool)> signInWithGoogle(bool linkApple) async {
  try {
    await GoogleSignIn.instance.initialize();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      return (
        false,
        'Esta plataforma requiere un flujo de autenticación específico',
        false,
      );
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
      return (false, 'No se obtuvieron credenciales válidas', false);
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: authorization?.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    if (linkApple) {
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

    final customerResult = await ServicesAPI().verifyAndCreateCustomer(null);
    if (customerResult.success) {
      await syncLocalCartWithFirestore();
      return (true, '', false);
    } else {
      if (customerResult.data?.canReactivate ?? false) {
        final message =
            customerResult.getError() ??
            'Cuenta eliminada, ¿Deseas recuperarla?';
        return (false, message, true);
      }
      if (userCredential.user != null) {
        final isSignedIn = await isGoogleSignedIn();
        if (isSignedIn) {
          print('sesion cerrada');
          await GoogleSignIn.instance.signOut();
        }
        await userCredential.user?.delete();
      }
      final message =
          customerResult.getError() ?? 'Ocurrió un error al iniciar sesión.';
      return (false, message, false);
    }
  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException ${e.toString()}');
    ServicesAPI().loggError({
      "level": "ERROR",
      "message": "Fallo elproceso de login Social",
      "context": {"error": e.toString()},
    });
    return (false, 'Ocurrió un error al iniciar sesión.', false);
  } catch (e) {
    ServicesAPI().loggError({
      "level": "ERROR",
      "message": "Fallo elproceso de login Social",
      "context": {"error": e.toString()},
    });
    return (false, 'Ocurrió un error al iniciar sesión.', false);
  }
}

Future<(bool, String, bool)> signInWithApple(
  BuildContext context,
  LoadingViewModel loading,
) async {
  try {
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

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      oauthCredential,
    );

    final email = userCredential.user?.email ?? '';

    if (email == '') {
      await userCredential.user?.delete();
      loading.hide();
      if (!context.mounted) {
        return (false, 'Ocurrió un error al iniciar sesión.', false);
      }
      String? email = await promptForEmail(context);
      if (email != null) {
        loading.show();
        final methods = await FirebaseAuthPlatform.instance
            .fetchSignInMethodsForEmail(email);
        if (methods.contains('apple.com')) {
          return (
            false,
            'El email ya está vinculado a Apple Sign-In de otro usuario',
            false,
          );
        } else if (methods.contains('password') ||
            methods.contains('google.com')) {
          if (!context.mounted) {
            return (false, 'Ocurrió un error al iniciar sesión.', false);
          }
          showCustomCupertinoActionSheet(
            context,
            email,
            methods.contains('google.com'),
            methods.contains('password'),
            loading,
          );
          return (false, '', false);
        } else {
          print('No hay ninguna cuenta asociada a este email.');

          final emailUserCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: email,
                password: generateRandomPassword(),
              );

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
          await emailUserCredential.user?.linkWithCredential(oauthCredential);

          final customerResult = await ServicesAPI().verifyAndCreateCustomer(
            null,
          );
          if (customerResult.success) {
            await sendEmailVerification();
            await syncLocalCartWithFirestore();
            return (true, '', false);
          } else {
            if (customerResult.data?.canReactivate ?? false) {
              final message =
                  customerResult.getError() ??
                  'Cuenta eliminada, ¿Deseas recuperarla?';
              return (false, message, true);
            }
            if (userCredential.user != null) {
              await userCredential.user?.delete();
            }
            final message =
                customerResult.getError() ??
                'Ocurrió un error al iniciar sesión.';
            return (false, message, false);
          }
        }
      } else {
        await userCredential.user?.delete();
        return (false, '', false);
      }
    } else {
      final fullName =
          appleCredential.givenName != null
              ? '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim()
              : null;

      await userCredential.user?.updateDisplayName(fullName);
      final customerResult = await ServicesAPI().verifyAndCreateCustomer(null);
      if (customerResult.success) {
        return (true, '', false);
      } else {
        if (customerResult.data?.canReactivate ?? false) {
          final message =
              customerResult.getError() ??
              'Cuenta eliminada, ¿Deseas recuperarla?';
          return (false, message, true);
        }
        if (userCredential.user != null) {
          await userCredential.user?.delete();
        }
        final message =
            customerResult.getError() ?? 'Ocurrió un error al iniciar sesión.';
        return (false, message, false);
      }
    }
  } on SignInWithAppleAuthorizationException catch (e) {
    ServicesAPI().loggError({
      "level": "ERROR",
      "message": "Fallo elproceso de login mediante apple",
      "context": {"error": e.toString()},
    });
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        return (false, '', false);
      case AuthorizationErrorCode.failed:
        return (false, 'Falló el inicio de sesión.', false);
      case AuthorizationErrorCode.invalidResponse:
        return (false, 'Respuesta inválida.', false);
      case AuthorizationErrorCode.notHandled:
        return (false, 'No se pudo manejar la solicitud.', false);
      case AuthorizationErrorCode.unknown:
        return (false, 'Error desconocido de Apple: ${e.message}', false);
      default:
        return (false, '', false);
    }
  } on FirebaseAuthException catch (e) {
    ServicesAPI().loggError({
      "level": "ERROR",
      "message": "Fallo elproceso de login mediante apple",
      "context": {"error": e.toString()},
    });
    return (false, 'Ocurrió un error al iniciar sesión.', false);
  } catch (e) {
    ServicesAPI().loggError({
      "level": "ERROR",
      "message": "Fallo elproceso de login mediante apple",
      "context": {"error": e.toString()},
    });
    return (false, 'Ocurrió un error al iniciar sesión.', false);
  }
}

void verifyUserInitialFlow(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  AnalyticsService().trackEvent("User login success");
  if (user.emailVerified) {
    final isEnableNotifications = await haveNotificationPermission();
    if (!context.mounted) return;
    if (isEnableNotifications) {
      final token = await FirebaseMessaging.instance.getToken();
      print('token de firebase: $token');
      if (token != null) {
        await ServicesAPI().setToken(token);
      }
      if (!context.mounted) return;
      if (Session.screenParent != null) {
        if (Session.screenPostLoggin != null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Session.screenPostLoggin!,
            (route) {
              return route.settings.name == Session.screenParent;
            },
          );
        } else {
          Navigator.popUntil(context, (route) {
            return route.settings.name == Session.screenParent;
          });
        }
        Session.screenParent = null;
        Session.screenPostLoggin = null;
      } else {
        Navigator.pushNamed(context, '/home');
      }
    } else {
      Navigator.pushNamed(context, '/enableNotifications');
    }
  } else {
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/verifyEmail');
  }
}

Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    await deleteCart();
    AnalyticsService().reset();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SplashScreen()),
        (route) => false,
      );
    }
    // });
  } catch (e) {
    print('Error al cerrar sesión: $e');
  }
}

Future<void> deleteAccount(BuildContext context) async {
  final loading = Provider.of<LoadingViewModel>(context, listen: false);
  try {
    loading.show();
    final response = await ServicesAPI().deleteUser();
    // if (response.success) {
    FirebaseAuth.instance.signOut();
    AnalyticsService().reset();
    await deleteCart();
    await GoogleSignIn.instance.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Phoenix.rebirth(context);
    });
    // }
  } catch (e) {
    print('Error al cerrar sesión: $e');
  } finally {
    loading.hide();
  }
}

Future<void> reactivateAlert(BuildContext context, String? message) async {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: MyColors.backgroundColor,
          title: Text(
            "Cuenta eliminada",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: getTextColor(context),
            ),
          ),
          content: Text(
            message ?? "¿Deseas recuperar la cuenta?",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: getTextColor(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await user.delete();
                    print('✅ Cuenta eliminada correctamente');
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'requires-recent-login') {
                      print(
                        '⚠️ El usuario debe volver a autenticarse antes de eliminar la cuenta',
                      );
                    } else {
                      print('❌ Error al eliminar la cuenta: ${e.code}');
                    }
                  }
                }
              },
              child: Text(
                "Cancelar",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: getTextColor(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                recoverAccount(context);
              },
              child: Text(
                "Recuperar",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: getTextColor(context),
                ),
              ),
            ),
          ],
        ),
  );
}

Future<void> recoverAccount(BuildContext context) async {
  final loading = Provider.of<LoadingViewModel>(context, listen: false);

  try {
    loading.show();
    final response = await ServicesAPI().recoverUser();
    if (response.success) {
      await syncLocalCartWithFirestore();
      AnalyticsService().identifyUser();
      if (!context.mounted) return;
      verifyUserInitialFlow(context);
    }
  } catch (e) {
    print('Error al cerrar sesión: $e');
  } finally {
    loading.hide();
  }
}

Future<bool> isGoogleSignedIn() async {
  try {
    final googleUser =
        await GoogleSignIn.instance.attemptLightweightAuthentication();
    return googleUser != null;
  } catch (e) {
    print('Error al verificar estado de autenticación: $e');
    return false;
  }
}

