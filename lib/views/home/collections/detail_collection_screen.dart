import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/grid_section.dart';
import 'package:mobile_app_template/components/image_slider.dart';
import 'package:mobile_app_template/components/list_products_section.dart';
import 'package:mobile_app_template/components/list_section.dart';
import 'package:mobile_app_template/components/general_section.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/collections/detail_collection_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DetailCollectionScreen extends StatefulWidget {
  final String? collectionId;
  final Collection? collection;
  final bool showBack;
  // final bool showPetHealth;

  DetailCollectionScreen({
    super.key,
    this.collectionId,
    this.collection,
    this.showBack = true,
    // this.showPetHealth = false,
  });

  @override
  DetailCollectionScreenState createState() => DetailCollectionScreenState();
}

class DetailCollectionScreenState extends State<DetailCollectionScreen> {
  /// NavBarHeader searchBelow: false, sin children → altura del contenedor superior
  static const double _collectionNavBarReserveHeight = 76;

  late DetailCollectionViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = DetailCollectionViewModel();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.collectionId != null) {
        viewModel.setCollectionId(widget.collectionId!);
      }
      if (widget.collection != null) {
        viewModel.updateCollection(widget.collection!);
      }
      viewModel.fetchCollection();
    });
  }

  Future<void> _handleRefresh() async {
    viewModel.fetchCollection();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print('mostrando pantalla');
  //   if (viewModel.listProducts.isEmpty) {
  //     viewModel.fetchProducts();
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      print('scroll');
      if (viewModel.pageInfo != null) {
        if (viewModel.pageInfo!.hasNextPage ?? false) {
          viewModel.updateafter(viewModel.pageInfo?.endCursor);
          viewModel.fetchProducts();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<DetailCollectionViewModel>(
        builder: (context, vm, _) {
          return VisibilityDetector(
            key: const Key('detail_colleciton_screen'),
            onVisibilityChanged: (_) {},
            child: CustomScaffold(
              blockBack: !widget.showBack,
              child: SafeArea(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        viewModel.isLoading
                            ? Padding(
                              padding: EdgeInsetsGeometry.only(
                                top: _collectionNavBarReserveHeight + 20,
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
                                    controller: _scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: SizedBox(
                                          height:
                                              _collectionNavBarReserveHeight,
                                        ),
                                      ),
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 20,
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                spacing: 10,
                                                children: [
                                                  if (viewModel.collection
                                                          ?.getHeaderImageMetafield() !=
                                                      null)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      child: Image.network(
                                                        viewModel.collection
                                                                ?.getHeaderImageMetafield() ??
                                                            '',
                                                        fit: BoxFit.cover,
                                                        width: 37,
                                                        height: 37,
                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          } else {
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    strokeWidth:
                                                                        1.5,
                                                                  ),
                                                            );
                                                          }
                                                        },
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons.error,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Text(
                                                      viewModel.title,
                                                      style: TextStyle(
                                                        fontFamily: 'NeulisAlt',
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ...viewModel.detailCollectionSections.map((
                                        section,
                                      ) {
                                        switch (section.getType()) {
                                          case 'slider':
                                            return SliverToBoxAdapter(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 20,
                                                ),
                                                child: ImageSlider(
                                                  imageUrls:
                                                      section.getImages(),
                                                ),
                                              ),
                                            );
                                          case 'list':
                                            return SliverToBoxAdapter(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 20,
                                                ),
                                                child: ListSection(
                                                  title:
                                                      section
                                                          .getHeaderTitle() ??
                                                      section.title,
                                                  description:
                                                      section.description,
                                                  username:
                                                      viewModel.user
                                                          ?.getName() ??
                                                      '',
                                                  categories:
                                                      section
                                                          .getSubcategories(),
                                                  onTapCollection:
                                                      (e) =>
                                                          viewModel.goToDetail(
                                                            context,
                                                            e,
                                                          ),
                                                ),
                                              ),
                                            );
                                          case 'grid':
                                            return SliverToBoxAdapter(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 20,
                                                ),
                                                child: GridSection(
                                                  title:
                                                      section
                                                          .getHeaderTitle() ??
                                                      section.title,
                                                  categories:
                                                      section
                                                          .getSubcategories(),
                                                  onTap:
                                                      (e) =>
                                                          viewModel.goToDetail(
                                                            context,
                                                            e,
                                                          ),
                                                ),
                                              ),
                                            );
                                          case 'section':
                                            return SliverToBoxAdapter(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 20,
                                                ),
                                                child: GeneralSection(
                                                  title:
                                                      section
                                                          .getHeaderTitle() ??
                                                      section.title,
                                                  description:
                                                      section.description ?? '',
                                                  backgroundColor: hexToColor(
                                                    section.getBackgroundColor() ??
                                                        '',
                                                  ),
                                                  imageUrls:
                                                      section.getImages(),
                                                  // products: section.products,
                                                  productParentId: section.id,
                                                  showMoreBtn: true,
                                                  onTap:
                                                      (e) => viewModel
                                                          .goToProductDetail(
                                                            context,
                                                            e,
                                                          ),
                                                  onTapSection:
                                                      () =>
                                                          viewModel.goToDetail(
                                                            context,
                                                            section,
                                                          ),
                                                ),
                                              ),
                                            );
                                          case 'ai_section':
                                            final title =
                                                section.getHeaderTitle() ??
                                                section.title;
                                            final description =
                                                section.description ??
                                                'Recibe recomendaciones personalizadas para tu mascota';
                                            return SliverToBoxAdapter(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 40,
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 20,
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          28,
                                                        ),
                                                    onTap: () {
                                                      viewModel.goToPetHealth(
                                                        context,
                                                      );
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 14,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                              begin:
                                                                  Alignment
                                                                      .topLeft,
                                                              end:
                                                                  Alignment
                                                                      .bottomRight,
                                                              colors: [
                                                                Color(
                                                                  0xFFE3501F,
                                                                ),
                                                                Color(
                                                                  0xFFF76B4C,
                                                                ),
                                                              ],
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              28,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    14,
                                                                  ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .auto_awesome,
                                                              color:
                                                                  MyColors
                                                                      .textBtnColor,
                                                              size: 28,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 14,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  title,
                                                                  style: TextStyle(
                                                                    color:
                                                                        MyColors
                                                                            .textBtnColor,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        'Poppins',
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  description,
                                                                  style: TextStyle(
                                                                    color:
                                                                        MyColors
                                                                            .textBtnColor,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        'Poppins',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .chevron_right_rounded,
                                                            color:
                                                                MyColors
                                                                    .textBtnColor,
                                                            size: 34,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 20,
                                          ),
                                          child: Divider(
                                            color: Colors.grey.shade200,
                                            height: 2,
                                          ),
                                        ),
                                      ),
                                      if (viewModel.listProducts.isNotEmpty)
                                        SliverToBoxAdapter(
                                          child: SizedBox(
                                            height:
                                                (viewModel.listProducts.length *
                                                    230) +
                                                220,
                                            child: ListProductsSection(
                                              // controller: _scrollController,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              products: viewModel.listProducts,
                                              handleOnTap:
                                                  (e) => viewModel
                                                      .goToProductDetail(
                                                        context,
                                                        e,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      if (vm.isProductLoading)
                                        SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsetsGeometry.only(
                                              top: 20,
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.grey,
                                                strokeWidth: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: NavBarHeader(
                        searchBelow: false,
                        showImageApp: false,
                        showSearch: true,
                        showShoppingCart: true,
                        showBackButton: widget.showBack,
                      ),
                    ),
                    // if (widget.showPetHealth)
                    //   Positioned(
                    //     bottom: Platform.isIOS ? 80 : 20,
                    //     left: 20,
                    //     right: 20,
                    //     child: CustomButton(
                    //       onPressed:
                    //           () => {
                    //             if (widget.showPetHealth)
                    //               {viewModel.goToPetHealth(context)},
                    //           },
                    //       label:
                    //           widget.showPetHealth
                    //               ? 'Cuidados para tu mascota'
                    //               : '',
                    //       type: CustomButtonType.filled,
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

