import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/Services/services_config.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:mobile_app_template/views/splash/splash_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashViewModel viewModel;

  @override
  void initState() {
    super.initState();
    ServicesAPI().obtainRecurrenceFrequency();
    viewModel = SplashViewModel();
    _obtainRecurrenceFrequency();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.checkLoginStatus();
    });
  }

  void _obtainRecurrenceFrequency() async {
    final response = await ServicesConfig().getFrecuencies();
    if (response.success) {
      saveRecurrenceFrequencies(response.data ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<SplashViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.goToTarget) {
              viewModel.setGoToTarget(false);
              Navigator.pushNamed(context, viewModel.targetPath);
            }
          });
          return CustomScaffold(
            backgroundColor: MyColors.splashBackground,
            useSafeArea: false,
            child: Center(
              child: SizedBox(
                width: 200,
                child: Image.asset(
                  'assets/images/splash.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

