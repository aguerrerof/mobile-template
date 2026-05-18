import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/main.dart' show navigatorKey, routeObserver;
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/home/address/address_list_screen.dart';
import 'package:mobile_app_template/views/home/address/create_edit_address_screen.dart';
import 'package:mobile_app_template/views/home/billing/customer/create_edit_customer_billing_data_screen.dart';
import 'package:mobile_app_template/views/home/billing/customer/customer_billing_data_list_screen.dart';
import 'package:mobile_app_template/views/home/checkout/checkout_screen.dart';
import 'package:mobile_app_template/views/home/collections/detail_collection_screen.dart';
import 'package:mobile_app_template/views/home/home_screen.dart';
import 'package:mobile_app_template/views/home/menu/changePassword/change_password_screen.dart';
import 'package:mobile_app_template/views/home/menu/edit_profile_screen.dart';
import 'package:mobile_app_template/views/home/order/detail/order_detail_screen.dart';
import 'package:mobile_app_template/views/home/order/recurring_detail/recurring%20_order_detail_screen.dart';
import 'package:mobile_app_template/views/home/order/list/order_list_screen.dart';
import 'package:mobile_app_template/views/home/payments/list/credit_card_list_screen.dart';
import 'package:mobile_app_template/views/home/payments/new_card_screen.dart';
import 'package:mobile_app_template/views/home/payments/validation_3ds_view.dart';
import 'package:mobile_app_template/views/home/petHealth/pet_health_wizard.dart';
import 'package:mobile_app_template/views/home/products/product_detail_screen.dart';
import 'package:mobile_app_template/views/home/search/search_screen.dart';
import 'package:mobile_app_template/views/home/shopingCart/Confirmation/confirmation_add_shoping_cart_screen.dart';
import 'package:mobile_app_template/views/home/shopingCart/shoping_cart_screen.dart';
import 'package:mobile_app_template/views/home/summary/summary_screen.dart';
import 'package:mobile_app_template/views/loading/global_loading_screen.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/login/login_screen_step_one.dart';
import 'package:mobile_app_template/views/login/login_screen_step_two.dart';
import 'package:mobile_app_template/components/notFound/not_found_screen.dart';
import 'package:mobile_app_template/views/notifications/notification_screen.dart';
import 'package:mobile_app_template/components/page_sheet/verify_email_screen.dart';
import 'package:mobile_app_template/views/register/register_screen_step_one.dart';
import 'package:mobile_app_template/views/register/register_screen_step_two.dart';
import 'package:mobile_app_template/views/splash/splash_screen.dart';
import 'package:mobile_app_template/views/theme/custom_colors.dart';
import 'package:mobile_app_template/views/tracking/traking_screen.dart';
import 'package:mobile_app_template/views/verificationCode/verification_code.dart';
import 'package:mobile_app_template/views/welcome/welcome_screen.dart';
import 'package:provider/provider.dart';

class PlatformApp extends StatelessWidget {
  final Widget home;

  const PlatformApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (Platform.isIOS) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            CupertinoApp(
              // showPerformanceOverlay: true,
              navigatorKey: navigatorKey,
              navigatorObservers: [routeObserver],
              theme:
                  brightness == Brightness.dark
                      ? CustomColorsTheme.darkCupertinoTheme
                      : CustomColorsTheme.lightCupertinoTheme,
              localizationsDelegates: const [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              home: home,
              onGenerateRoute: (settings) {
                return CupertinoPageRoute(
                  settings: settings,
                  builder: (context) => _buildRoute(settings),
                );
              },
            ),
            Consumer<LoadingViewModel>(
              builder: (context, loader, _) {
                return loader.loading
                    ? const GlobalLoader()
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      );
    } else {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            MaterialApp(
              // showPerformanceOverlay: true,
              navigatorKey: navigatorKey,
              navigatorObservers: [routeObserver],
              theme: CustomColorsTheme.lightMaterialTheme,
              darkTheme: CustomColorsTheme.darkMaterialTheme,
              themeMode: ThemeMode.system,
              home: home,
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => _buildRoute(settings),
                );
              },
              // navigatorObservers: [PosthogObserver(),],
            ),
            Consumer<LoadingViewModel>(
              builder: (context, loader, _) {
                return loader.loading
                    ? const GlobalLoader()
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/welcome':
        return WelcomeScreen();
      case '/login-one':
        return LoginScreenStepOne();
      case '/login-step-two':
        final args = settings.arguments as Map<String, dynamic>?;
        final linkApple = args?['linkApple'] as bool? ?? false;
        return LoginScreenStepTwo(linkApple: linkApple);
      case '/register':
        return RegisterScreen();
      case '/register-step-two':
        return RegisterScreenStepTwo();
      case '/enableNotifications':
        return EnableNotificationsScreen();
      case '/home':
        final args = settings.arguments as Map<String, dynamic>?;
        final tabIndex = args?['tabIndex'] as int? ?? 0;
        return HomeScreen(initialIndex: tabIndex);
      case '/detailCollection':
        final args = settings.arguments;
        if (args is Map<String, dynamic> &&
            (args['collection'] is Collection ||
                args['collectionId'] is String)) {
          final collection = args['collection'] as Collection?;
          final collectionId = args['collectionId'] as String?;
          final showBack = args['showBack'] as bool;
          return DetailCollectionScreen(
            collectionId: collectionId,
            collection: collection,
            showBack: showBack,
          );
        } else {
          return NotFoundScreen();
        }
      case '/productDetail':
        final product = settings.arguments as Product;
        return ProductDetailScreen(product: product);
      case '/searchScreen':
        return SearchScreenFull();
      case '/verifyEmail':
        return EmailVerificationScreen();
      case '/shopingCart':
        return ShoppingCartScreen();
      case '/checkout':
        return CheckoutScreen();
      case '/address':
        final args = settings.arguments as Map<String, dynamic>?;
        final address = args?['address'] as Address?;
        return CreateOrEditAddressScreen(address: address);
      case '/listAddresses':
        final args = settings.arguments as Map<String, dynamic>?;
        final isEditable = args?['isEditable'] as bool? ?? false;
        return AddressListScreen(canEdit: isEditable);
      case '/summary':
        final args = settings.arguments as Map<String, dynamic>?;
        final order = args?['order'] as ShopifyOrder?;
        return SummaryScreen(order: order!);
      case '/orderList':
        final args = settings.arguments as Map<String, dynamic>?;
        final recurring = args?['recurring'] as bool? ?? false;
        return OrderListScreen(recurring: recurring);
      case '/recurringOrderDetail':
        final args = settings.arguments as Map<String, dynamic>?;
        final order = args?['order'] as RecurringOrder?;
        return RecurringOrderScreen(order: order);
      case '/cardsList':
        final args = settings.arguments as Map<String, dynamic>?;
        final isSelectionEnable = args?['isSelectionEnable'] as bool? ?? false;
        return CreditCardListScreen(isSelectionEnable: isSelectionEnable);
      case '/registerCreditCard':
        final args = settings.arguments as Map<String, dynamic>?;
        final fromCheckout = args?['isFromCheckout'] as bool? ?? false;
        return CreateCardScreen(fromCheckout: fromCheckout);
      case '/listCustomerBilling':
        final args = settings.arguments as Map<String, dynamic>?;
        final isEditable = args?['isEditable'] as bool? ?? false;
        final fromCredit = args?['isForCreditCard'] as bool? ?? false;
        return CustomerBillingDataListScreen(
          canEdit: isEditable,
          isForCreditCard: fromCredit,
        );
      case '/customerBilling':
        final args = settings.arguments as Map<String, dynamic>?;
        final customer = args?['customer'] as CustomerBilling?;
        final setDefault = args?['setDefault'] as bool? ?? false;
        return CreateOrEditCustomerBillingDataScreen(
          customer: customer,
          setDefault: setDefault,
        );
      case '/editProfile':
        return EditProfileScreen();
      case '/changePassword':
        return ChangePasswordScreen();
      case '/verificationCode':
        final args = settings.arguments as Map<String, dynamic>?;
        final flow = args?['flow'] as FlowsCodeVerification;
        final subtitle = args?['subtitle'] as String?;
        final paymentCard = args?['paymentCard'] as PaymentCardModel;
        return VerificationCode(
          flow: flow,
          subtitle: subtitle,
          paymentCard: paymentCard,
        );

      case '/validations3DS':
        final args = settings.arguments as Map<String, dynamic>?;
        final url = args?['url'] as String;
        return ModalValidation3DSView(urlString: url);
      case '/listCreditCard':
        final args = settings.arguments as Map<String, dynamic>?;
        final isSelectionable = args?['selectionable'] as bool;
        return CreditCardListScreen(isSelectionEnable: isSelectionable);
      case '/orderDetail':
        final args = settings.arguments as Map<String, dynamic>?;
        final order = args?['order'] as Order?;
        return OrderScreen(order: order);
      case '/trackingScreen':
        return EnableTrackingScreen();
      case '/ConfirmationAddCard':
        final args = settings.arguments as Map<String, dynamic>?;
        final product = args?['product'] as Product;
        final isRecurrence = args?['isRecurrence'] as bool?;
        return ConfirmationAddShoppingCartScreen(
          product: product,
          isRecurrence: isRecurrence,
        );
      case '/petHealth':
        // final args = settings.arguments as Map<String, dynamic>?;
        // final product = args?['product'] as Product;
        // final isRecurrence = args?['isRecurrence'] as bool?;
        return PetHealthWizard();
      // case '/demo':
      //   return CurrencyDemoScreen();
      default:
        return SplashScreen();
    }
  }
}

