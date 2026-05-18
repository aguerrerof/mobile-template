import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/config/config.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/discover/discover_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/login/login_viewmodel.dart';
import 'package:mobile_app_template/views/register/register_viewmodel.dart';
import 'package:mobile_app_template/views/splash/splash_screen.dart';
import 'package:mobile_app_template/platform_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_template/views/theme/theme_detector.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:singular_flutter_sdk/singular_config.dart';
import 'package:singular_flutter_sdk/singular_link_params.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebaseMessaging();

  await Hive.initFlutter();
  await Hive.openBox('cart');
  await Hive.openBox('recurrenceFrequency');
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  ThemeDetector();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final config = PostHogConfig(
    const String.fromEnvironment('POSTHOG_API_KEY'),
  );
  config.debug = true;
  config.captureApplicationLifecycleEvents = true;
  config.sessionReplay = true;
  config.sessionReplayConfig.maskAllTexts = false;
  config.sessionReplayConfig.maskAllImages = false;
  config.sessionReplayConfig.throttleDelay = const Duration(
    milliseconds: 10000,
  );
  config.host = 'https://us.i.posthog.com';
  await Posthog().setup(config);

  SingularConfig configSingular = SingularConfig(
    GeneralConfig.singularKey,
    GeneralConfig.singularSecret,
  );
  configSingular.skAdNetworkEnabled = true;
  configSingular.limitDataSharing = false;
  configSingular.manualSkanConversionManagement = false;
  configSingular.singularLinksHandler = (SingularLinkParams params) {
    print('Deep link received: ${params.deeplink}');
    print('Passthrough params: ${params.passthrough}');
    print('Is deferred: ${params.isDeferred}');
  };
  configSingular.shortLinkResolveTimeOut = 10.0;

  Singular.start(configSingular);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadingViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider<CartProvider>.value(
          value: CartProvider.instance,
        ),
        ChangeNotifierProvider(create: (_) => DiscoverViewModel()),
      ],
      child: PostHogWidget(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformApp(home: SplashScreen());
  }
}

