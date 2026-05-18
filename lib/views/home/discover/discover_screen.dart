import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/grid_section.dart';
import 'package:mobile_app_template/components/image_slider.dart';
import 'package:mobile_app_template/components/list_section.dart';
import 'package:mobile_app_template/components/general_section.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/discover/discover_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  DiscoverScreen({super.key});

  @override
  DiscoverScreenState createState() => DiscoverScreenState();
}

class DiscoverScreenState extends State<DiscoverScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Home Screen');
    syncTokenIfLoggedIn();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DiscoverViewModel>(context, listen: false).fetchUser();
        Provider.of<DiscoverViewModel>(
          context,
          listen: false,
        ).fetchHomePageCollection();
      });
    }
  }

  Future<void> _handleRefresh() async {
    Provider.of<DiscoverViewModel>(
      context,
      listen: false,
    ).fetchHomePageCollection();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiscoverViewModel>();
    final loading = Provider.of<LoadingViewModel>(context);

    if (viewModel.errorString.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomFlushbar(context, message: viewModel.errorString);
        viewModel.setError('');
        AnalyticsService().identifyUser();
      });
    }

    // Altura del NavBarHeader con searchBelow + showSearch (fila 53 + buscador ~56)
    const double _discoverNavBarReserveHeight = 109;

    return SafeArea(
      child: Stack(
        // clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              viewModel.isLoading
                  ? Padding(
                    padding: EdgeInsetsGeometry.only(
                      top: _discoverNavBarReserveHeight + 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      ],
                    ),
                  )
                  : Expanded(
                    child: RefreshIndicator(
                      backgroundColor: Colors.white,
                      color: MyColors.btnColor,
                      onRefresh: _handleRefresh,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MyColors.backgroundColor,
                        ),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: _discoverNavBarReserveHeight,
                              ),
                            ),
                            ...viewModel.discoverSections.map((section) {
                              final needService =
                                  section.getServiceName() != null;
                              switch (section.getType()) {
                                case 'slider':
                                  return SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: ImageSlider(
                                        imageUrls: section.getImages(),
                                      ),
                                    ),
                                  );
                                case 'list':
                                  if (needService) {
                                    // return const SliverToBoxAdapter(
                                    //   child: SizedBox.shrink(),
                                    // );
                                    return SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: ListSection(
                                          title:
                                              section.getHeaderTitle() ??
                                              section.title,
                                          isPrincipal: false,
                                          description: section.description,
                                          username: '',
                                          categories: [],
                                          type: CategoryCellVisualType.product,
                                          onTapProduct: (e) {
                                            addToCart(
                                              context: context,
                                              loading: loading,
                                              product: e,
                                              count: 1,
                                              goToConfirmCart: true,
                                              showBottomDetail: false,
                                              showPopup: false,
                                              isRecurrence: false,
                                              applyDiscount: false,
                                            );
                                          },
                                          serviceName: section.getServiceName(),
                                          isDynamicContent: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: ListSection(
                                          title:
                                              section.getHeaderTitle() ??
                                              section.title,
                                          isPrincipal:
                                              section.isPrincipal() ?? false,
                                          description: section.description,
                                          username:
                                              viewModel.user?.getName() ?? '',
                                          categories:
                                              section.getSubcategories() ?? [],
                                          onTapCollection:
                                              (e) => viewModel.goToDetail(
                                                context,
                                                e,
                                              ),
                                        ),
                                      ),
                                    );
                                  }

                                case 'grid':
                                  return SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: GridSection(
                                        title:
                                            section.getHeaderTitle() ??
                                            section.title,
                                        categories:
                                            section.getSubcategories() ?? [],
                                        onTap:
                                            (e) => viewModel.goToDetail(
                                              context,
                                              e,
                                            ),
                                      ),
                                    ),
                                  );
                                case 'section':
                                  return SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: GeneralSection(
                                        title:
                                            section.getHeaderTitle() ??
                                            section.title,
                                        titleStyle: TextStyle(
                                          fontSize:
                                              section.isPrincipal() ?? false
                                                  ? 24
                                                  : 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'NeulisAlt',
                                        ),
                                        description: section.description ?? '',
                                        backgroundColor: hexToColor(
                                          section.getBackgroundColor() ?? '',
                                        ),
                                        imageUrls: section.getImages(),
                                        // products: section.products,
                                        productParentId: section.id,
                                        showMoreBtn: true,
                                        onTap:
                                            (e) => viewModel.goToProductDetail(
                                              context,
                                              e,
                                            ),
                                        onTapSection:
                                            () => viewModel.goToDetail(
                                              context,
                                              section,
                                            ),
                                      ),
                                    ),
                                  );
                                default:
                                  return const SliverToBoxAdapter(
                                    child: SizedBox.shrink(),
                                  );
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
              Platform.isIOS
                  ? const SizedBox(height: 60)
                  : const SizedBox.shrink(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavBarHeader(
              searchBelow: true,
              showImageApp: true,
              showSearch: true,
              showShoppingCart: true,
              showBackButton: false,
            ),
          ),
        ],
      ),
    );
  }
}

