import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/config/config.dart';
import 'package:mobile_app_template/main.dart' show routeObserver;
import 'package:mobile_app_template/utils/session_helper.dart';
import 'package:mobile_app_template/views/home/collections/detail_collection_screen.dart';
import 'package:mobile_app_template/views/home/discover/discover_screen.dart';
import 'package:mobile_app_template/views/home/home_view_model.dart';
import 'package:mobile_app_template/views/home/menu/menu_screen.dart';
import 'package:mobile_app_template/views/home/order/list/order_list_screen.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:mobile_app_template/utils/notification_manager.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with RouteAware {
  late HomeViewModel viewModel;
  bool _isRouteObserverSubscribed = false;
  final List<Widget> _screens = [
    DiscoverScreen(),
    DetailCollectionScreen(
      collectionId: GeneralConfig.healthyCollectionId,
      showBack: false,
      // showPetHealth: true,
    ),
    OrderListScreen(recurring: false),
    MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    viewModel.updateIndex(widget.initialIndex.clamp(0, 3));
    _consumePendingHomeTabNavigation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.getCart(context);
      _checkPendingNotification();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_isRouteObserverSubscribed && route is PageRoute) {
      routeObserver.subscribe(this, route);
      _isRouteObserverSubscribed = true;
    }
  }

  void _consumePendingHomeTabNavigation() {
    final pendingTab = Session.pendingHomeTabIndex;
    if (pendingTab == null) return;

    Session.pendingHomeTabIndex = null;
    viewModel.updateIndex(pendingTab.clamp(0, 3));
  }

  @override
  void didPopNext() {
    _consumePendingHomeTabNavigation();
  }

  @override
  void dispose() {
    if (_isRouteObserverSubscribed) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  void _checkPendingNotification() {
    // Verificar si hay una notificación pendiente y procesarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingNotification();
    });
  }

  Future<void> _processPendingNotification() async {
    // Esperar un momento para asegurar que todo esté inicializado
    await Future.delayed(const Duration(milliseconds: 500));

    // Verificar si hay una notificación pendiente y procesarla
    if (mounted && NotificationManager().hasPendingNotification()) {
      print('Procesando notificación pendiente en HomeScreen');
      await NotificationManager().processPendingNotification(context);
    }
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return CustomScaffold(
            backgroundColor: MyColors.backgroundColor,
            navBarColor: MyColors.navBarBackground,
            blockBack: true,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 30.0,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              // padding: EdgeInsets.only(top: 5),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Color(0xFFFFFEFB),
                    currentIndex: viewModel.currentIndex,
                    selectedItemColor: MyColors.btnColor,
                    unselectedItemColor: Color(0XFF4D4D4D),
                    onTap: (index) {
                      print("index seleccionado $index");

                      setState(() {
                        viewModel.updateIndex(index);
                      });
                    },
                    selectedLabelStyle: TextStyle(
                      fontFamily: 'NeulisAlt',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: MyColors.btnColor,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'NeulisAlt',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0XFF4D4D4D),
                    ),
                    items: [
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Image.asset(
                            height: 25,
                            'assets/images/home.png',
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.srcIn,
                            color:
                                viewModel.currentIndex == 0
                                    ? MyColors.btnColor
                                    : MyColors.checkTextColor,
                          ),
                        ),
                        label: "Inicio",
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Image.asset(
                            height: 25,
                            'assets/images/heart.png',
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.srcIn,
                            color:
                                viewModel.currentIndex == 1
                                    ? MyColors.btnColor
                                    : MyColors.checkTextColor,
                          ),
                        ),
                        label: "Bienestar",
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Image.asset(
                            height: 25,
                            'assets/images/bill.png',
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.srcIn,
                            color:
                                viewModel.currentIndex == 2
                                    ? MyColors.btnColor
                                    : MyColors.checkTextColor,
                          ),
                        ),
                        label: "Pedidos",
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Image.asset(
                            height: 25,
                            'assets/images/person.png',
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.srcIn,
                            color:
                                viewModel.currentIndex == 3
                                    ? MyColors.btnColor
                                    : MyColors.checkTextColor,
                          ),
                        ),
                        label: "Perfil",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: IndexedStack(
              index: viewModel.currentIndex,
              children: _screens,
            ),
          );
        },
      ),
    );
  }
}

