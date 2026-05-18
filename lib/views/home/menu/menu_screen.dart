import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/main.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/session_helper.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/views/home/menu/profile_header.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> with RouteAware {
  User? user;
  final picker = ImagePicker();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    getProfile();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isUploading = true);

    final originalFile = File(pickedFile.path);
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      targetPath,
      quality: 50,
      format: CompressFormat.jpeg,
    );
    if (compressedFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${user!.uid}.jpg');

    try {
      final File file = File(compressedFile.path);
      await storageRef.putFile(file);
      final photoURL = await storageRef.getDownloadURL();
      await user.updatePhotoURL(photoURL);
      setState(() => isUploading = false);
      if (!mounted) return;
      showCustomFlushbar(
        context,
        message: 'Se actualizó tu foto de perfil',
        backgroundColor: MyColors.successAlertColor,
        textColor: MyColors.successAlerttextColor,
      );
      getProfile();
    } catch (e) {
      print(e);
      setState(() => isUploading = false);
      if (!mounted) return;
      showCustomFlushbar(
        context,
        message: 'Error al actualizar la foto de perfil',
      );
    }
  }

  Future<void> getProfile() async {
    try {
      setState(() {
        user = FirebaseAuth.instance.currentUser;
      });
    } catch (e) {
      print("Error inesperado: $e");
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 110,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Stack(
                      children: [
                        ProfileHeader(
                          name: user?.displayName ?? '',
                          email: user?.email ?? '',
                          imageString: user?.photoURL ?? '',
                          onPressed: pickAndUploadImage,
                        ),
                        if (isUploading)
                          Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300.withAlpha(100),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SectionTitle(title: 'Personal'),
                MenuCard(
                  items: [
                    MenuItem(
                      icon: CupertinoIcons.bag,
                      label: 'Tus Envíos Programados',
                      routeName: '/orderList',
                      arguments: {'recurring': true},
                    ),
                    MenuItem(
                      icon: CupertinoIcons.location,
                      label: 'Tus Direcciones',
                      routeName: '/listAddresses',
                      arguments: {'isEditable': true},
                    ),
                    MenuItem(
                      icon: CupertinoIcons.creditcard,
                      label: 'Tus métodos de pago',
                      routeName: '/listCreditCard',
                      arguments: {'selectionable': false},
                    ),
                    MenuItem(
                      icon: CupertinoIcons.person,
                      label: 'Tus datos de facturación',
                      routeName: '/listCustomerBilling',
                      arguments: {'isEditable': true},
                    ),
                  ],
                ),
              ],
            ),

          SectionTitle(title: 'Cuenta'),
          if (user != null)
            MenuCard(
              items: [
                MenuItem(
                  icon: CupertinoIcons.bell,
                  label: 'Notificaciones',
                  trailingText: 'On',
                ),
                MenuItem(
                  icon: CupertinoIcons.padlock,
                  label: "Cambiar contraseña",
                  routeName: '/changePassword',
                ),
                MenuItem(
                  icon: CupertinoIcons.lock_shield,
                  label: "Política de privacidad",
                  routeName: '/privacy-policies',
                ),
                MenuItem(
                  icon: CupertinoIcons.lock_shield,
                  label: "Términos y condiciones",
                  routeName: '/terms-conditions',
                ),
                MenuItem(
                  icon: CupertinoIcons.delete,
                  label: 'Eliminar cuenta',
                  isDeleteUSer: true,
                ),
                MenuItem(
                  icon: CupertinoIcons.square_arrow_right,
                  label: 'Cerrar sesión',
                  isLogout: true,
                ),
              ],
            ),
          if (user == null)
            MenuCard(
              items: [
                MenuItem(
                  icon: CupertinoIcons.square_arrow_right,
                  label: 'Iniciar sesión',
                  routeName: '/login-one',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// -----------------------------
// Subcomponentes
// -----------------------------

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final List<MenuItem> items;

  const MenuCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:
            items
                .asMap()
                .entries
                .map(
                  (entry) => Column(
                    children: [
                      if (entry.key > 0)
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: CupertinoColors.systemGrey4,
                        ),
                      entry.value,
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final String? routeName;
  final bool isLogout;
  final bool isDeleteUSer;
  final Object? arguments;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.trailingText,
    this.routeName,
    this.isLogout = false,
    this.arguments,
    this.isDeleteUSer = false,
  });

  void _handleTap(BuildContext context) {
    AnalyticsService().trackEvent("User click $label");
    if (isLogout) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder:
              (ctx) => CupertinoAlertDialog(
                title: Text("Cerrar sesión"),
                content: Text("¿Estás seguro de que deseas salir?"),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color:
                            CupertinoTheme.of(ctx).brightness == Brightness.dark
                                ? CupertinoColors.activeBlue
                                : CupertinoTheme.of(ctx).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      logout(context);
                    },
                    child: Text(
                      "Salir",
                      style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                backgroundColor: MyColors.backgroundColor,
                title: Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
                content: Text(
                  "¿Estás seguro de que deseas salir?",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
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
                      logout(context);
                    },
                    child: Text(
                      "Salir",
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
    } else if (isDeleteUSer) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder:
              (ctx) => CupertinoAlertDialog(
                title: Text("Eliminar Cuenta"),
                content: Text(
                  "¿Estás seguro de que deseas eliminar la cuenta?",
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        color:
                            CupertinoTheme.of(ctx).brightness == Brightness.dark
                                ? CupertinoColors.white
                                : CupertinoTheme.of(ctx).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      AnalyticsService().trackEvent("User deleted account");
                      deleteAccount(context);
                    },
                    child: Text("Eliminar"),
                  ),
                ],
              ),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                backgroundColor: MyColors.backgroundColor,
                title: Text(
                  "Eliminar Cuenta",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
                content: Text(
                  "¿Estás seguro de que deseas eliminar la cuenta?",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
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
                      Navigator.pop(ctx);
                      AnalyticsService().trackEvent("User deleted account");
                      deleteAccount(context);
                    },
                    child: Text(
                      "Eliminar",
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
    } else if (routeName != null) {
      if (routeName == '/login-one') {
        Session.screenParent = '/home';
      }
      if (routeName == '/privacy-policies') {
        openUrl(
          "https://drive.google.com/file/d/1jwYj2lW8BoJQ-zeK8EOQm8Uh-JmhOkN_/view?usp=drive_link",
        );
      }
      if (routeName == '/terms-conditions') {
        openUrl(
          "https://drive.google.com/file/d/1pw8wFw7wDUloLStdQveijAXwLXEMlXEb/view?usp=drive_link",
        );
      }
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed(routeName!, arguments: arguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
              ),
            ),
            if (trailingText != null)
              Text(trailingText!, style: TextStyle(color: Colors.grey))
            else
              const Icon(CupertinoIcons.forward, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

