import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/home/components/category_cell_rectangle.dart';
import 'package:mobile_app_template/views/home/components/category_cell_rectangle_oval.dart';
import 'package:mobile_app_template/views/home/components/product_cell.dart';

enum CategoryCellVisualType { circle, rectagle, product }

class ListSection extends StatefulWidget {
  final String title;
  final List<Collection> categories;
  final CategoryCellVisualType type;
  final void Function(Collection)? onTapCollection;
  final void Function(Product)? onTapProduct;
  final String? description;
  final String? username;
  final bool isPrincipal;
  final bool isDynamicContent;
  final String? serviceName;
  const ListSection({
    super.key,
    required this.title,
    required this.categories,
    this.onTapCollection,
    this.onTapProduct,
    this.type = CategoryCellVisualType.circle,
    this.description,
    this.username,
    this.isPrincipal = false,
    this.isDynamicContent = false,
    this.serviceName,
  });

  @override
  State<ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends State<ListSection> {
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  DynamicList? _dynamicItems;

  @override
  void initState() {
    super.initState();
    _tryLoadDynamicContent();
  }

  @override
  void didUpdateWidget(covariant ListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el serviceName o la bandera de contenido dinámico, recargamos
    if (oldWidget.serviceName != widget.serviceName ||
        oldWidget.isDynamicContent != widget.isDynamicContent) {
      _tryLoadDynamicContent();
    }
  }

  void _tryLoadDynamicContent() {
    if (widget.isDynamicContent && widget.serviceName != null) {
      _loadDynamicContent(widget.serviceName!);
    }
  }

  Future<void> _loadDynamicContent(String serviceName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _fetchDynamicCategories(serviceName);
      if (!mounted) return;

      setState(() {
        _dynamicItems = categories;
        _hasLoadedOnce = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dynamicItems = null;
        _hasLoadedOnce = true;
        _isLoading = false;
      });
    }
  }

  Future<DynamicList?> _fetchDynamicCategories(String serviceName) async {
    switch (serviceName) {
      case 'BUY_AGAIN':
        final result = await ServicesAPI().getProductsPreviouslyPurchased();

        if (result.success) {
          print('result: ${result.data}');
          final products = result.data;
          if (products == null) {
            throw Exception('No se encontró la ');
          }
          final newlist =
              products
                  .where((p) => p.purchased.isNotEmpty)
                  .expand(
                    (product) => product.purchased.map((purchasedVariant) {
                      return Product(
                        id: product.id,
                        title: product.title,
                        description: product.description,
                        variants: List.from(product.variants),
                        media: List.from(product.media),
                        selectedVariant: purchasedVariant,
                        productType: product.productType,
                        vendor: product.vendor,
                        tags: List.from(product.tags),
                        metafields: Map.from(product.metafields),
                        totalInventory: product.totalInventory,
                        purchased: List.from(product.purchased),
                      );
                    }),
                  )
                  .toList();
          final response = DynamicList<Product>();
          response.addItems(newlist);
          return response;
        } else {
          throw Exception(
            result.errors.isNotEmpty
                ? 'Error message: ${result.errors[0].message}'
                : 'Error al obtener el la',
          );
        }
      case 'SUGGESTIONS':
        await Future.delayed(const Duration(milliseconds: 500));
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDynamicContent && widget.serviceName != null) {
      if (_hasLoadedOnce && _dynamicItems == null) {
        return const SizedBox.shrink();
      }
    }

    final listCollection = DynamicList<Collection>();
    listCollection.addItems(widget.categories);

    final DynamicList itemsToShow =
        (widget.isDynamicContent && widget.serviceName != null)
            ? _dynamicItems ?? DynamicList<Collection>()
            : listCollection;

    if (itemsToShow.getSize() == 0) {
      return const SizedBox.shrink();
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double parentHorizontalPadding = 20;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title.replaceAll("@user", widget.username ?? ''),
                  style: TextStyle(
                    fontSize: widget.isPrincipal ? 22 : 16,
                    fontFamily: 'NeulisAlt',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.description != '')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.description ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          widget.isPrincipal
                              ? FontWeight.w400
                              : FontWeight.w500,
                      fontFamily: 'NeulisAlt',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        if (!widget.isPrincipal) const SizedBox(height: 14),
        if (widget.type == CategoryCellVisualType.circle)
          SizedBox(
            height: widget.isPrincipal ? 150 : 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: parentHorizontalPadding,
              ),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final needCenter = widget.categories.length <= 2;
                final screenWidth = MediaQuery.of(context).size.width;

                return Padding(
                  padding:
                      needCenter
                          ? index == 0
                              ? EdgeInsets.only(
                                left:
                                    ((screenWidth -
                                            ((parentHorizontalPadding * 2) +
                                                (10 *
                                                    widget.categories.length) +
                                                (widget.isPrincipal
                                                        ? 128
                                                        : 95) *
                                                    widget.categories.length)) /
                                        2),
                                right: 10,
                              )
                              : const EdgeInsets.only(right: 10)
                          : const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: widget.isPrincipal ? 133 : 100,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onTapCollection == null) return;
                        widget.onTapCollection!(category);
                      },
                      child: CategoryCellRectangleOval(
                        label: category.getHeaderTitle() ?? category.title,
                        imageUrl:
                            category.getImageMetafield() ?? category.imageUrl,
                        imageHeight: widget.isPrincipal ? 95 : 63,
                        textStyle:
                            widget.isPrincipal
                                ? TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NeulisAlt',
                                  height: 1,
                                )
                                : TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NeulisAlt',
                                  height: 1,
                                ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (widget.type == CategoryCellVisualType.rectagle)
          SizedBox(
            height: 270,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: parentHorizontalPadding,
              ),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: (screenWidth - 50) / 2,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onTapCollection == null) return;
                        widget.onTapCollection!(category);
                      },
                      child: CategoryCellRectangle(
                        label: category.title,
                        imageUrl:
                            category.getImageMetafield() ?? category.imageUrl,
                        description: category.description ?? '',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        if (widget.type == CategoryCellVisualType.product)
          SizedBox(
            height: 270,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: parentHorizontalPadding,
              ),
              itemCount: itemsToShow.getSize(),
              itemBuilder: (context, index) {
                final product = itemsToShow.getItem(index);
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: (screenWidth - 50) / 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/productDetail', arguments: product);
                      },
                      child: ProductCell(
                        product: product,
                        onAddPressed: () {
                          if (widget.onTapProduct == null) return;
                          widget.onTapProduct!(product);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

