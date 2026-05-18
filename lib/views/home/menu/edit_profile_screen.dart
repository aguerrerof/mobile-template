import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/views/home/menu/profile_header.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    getProfile();
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
      cupertinoNavigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      materialNavigationBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ProfileHeader(
                name: user?.displayName ?? '',
                email: user?.email ?? '',
                imageString: user?.photoURL ?? '',
                onPressed: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/editProfile').then((_) {
                    getProfile();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              title: 'Nombre',
              initialValue: user?.displayName ?? "",
              placeholder: 'Nombre',
            ),
            const SizedBox(height: 16),
            CustomTextField(title: 'Apellido', placeholder: 'Apellido'),
            const SizedBox(height: 16),
            CustomTextField(title: 'Email', placeholder: 'Email'),
            const SizedBox(height: 16),
            CustomTextField(title: 'Teléfono', placeholder: 'Teléfono'),
          ],
        ),
      ),
    );
  }
}

