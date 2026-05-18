import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/option_offer_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class ListProductsSection extends StatefulWidget {
  final List<Product> products;
  final Function(Product) handleOnTap;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const ListProductsSection({
    super.key,
    required this.products,
    required this.handleOnTap,
    this.controller,
    this.physics,
  });

  @override
  State<ListProductsSection> createState() => ListProductsSectionState();
}

class ListProductsSectionState extends State<ListProductsSection> {
  List<Product> _filteredProductList = const [];
  bool _showFilters = false;

  List<String?> _vendors = [];
  List<String?> _productTypes = [];
  List<String?> _tags = [];

  List<String?> _vendorsSelected = [];
  List<String?> _productTypesSelected = [];
  List<String?> _tagsSelected = [];

  void updateVendor() {
    final vendors =
        widget.products
            .map((product) => product.vendor)
            .where((vendor) => vendor != null && vendor.isNotEmpty)
            .toSet()
            .toList();
    setState(() {
      _vendors = vendors;
    });
  }

  void selectVendor(String vendor) {
    setState(() {
      if (!_vendorsSelected.contains(vendor)) {
        _vendorsSelected.add(vendor);
      } else {
        _vendorsSelected.removeWhere((item) => item == vendor);
      }
      updateFilteredProductList();
    });
  }

  void updateTypes() {
    final productTypes =
        widget.products
            .map((product) => product.productType)
            .where((type) => type != null && type.isNotEmpty)
            .toSet()
            .toList();
    setState(() {
      _productTypes = productTypes;
    });
  }

  void selectTypes(String type) {
    setState(() {
      if (!_productTypesSelected.contains(type)) {
        _productTypesSelected.add(type);
      } else {
        _productTypesSelected.removeWhere((item) => item == type);
      }
      updateFilteredProductList();
    });
  }

  void updateTags() {
    final tags =
        widget.products.expand((product) => product.tags).toSet().toList();
    setState(() {
      _tags = tags;
    });
  }

  void selectTag(String tag) {
    setState(() {
      if (!_tagsSelected.contains(tag)) {
        _tagsSelected.add(tag);
      } else {
        _tagsSelected.removeWhere((item) => item == tag);
      }
      updateFilteredProductList();
    });
  }

  void updateFilteredProductList() {
    setState(() {
      _filteredProductList = widget.products;
      if (_vendorsSelected.isNotEmpty) {
        _filteredProductList =
            _filteredProductList
                .where((product) => _vendorsSelected.contains(product.vendor))
                .toList();
      }
      if (_productTypesSelected.isNotEmpty) {
        _filteredProductList =
            _filteredProductList
                .where(
                  (product) =>
                      _productTypesSelected.contains(product.productType),
                )
                .toList();
      }
      if (_tags.isNotEmpty) {
        _filteredProductList =
            _filteredProductList
                .where(
                  (product) => _tags.any((tag) => product.tags.contains(tag)),
                )
                .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateFilteredProductList();
      updateVendor();
      updateTypes();
      updateTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<LoadingViewModel>(context);
    return
    // Expanded(
    //   child:
    Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredProductList.length} Resultados',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.filter_list,
                        label: 'Filtrar',
                        onTap:
                            () => setState(() {
                              _showFilters = !_showFilters;
                            }),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child:
                    _showFilters
                        ? Container(
                          padding: EdgeInsets.only(top: 10, bottom: 20),
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              if (_vendors.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Por marca:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 10,
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children:
                                              _vendors
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (entry) => Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 10,
                                                      ),
                                                      child: CustomButton(
                                                        label:
                                                            entry.value ?? '',
                                                        onPressed:
                                                            () => {
                                                              selectVendor(
                                                                entry.value ??
                                                                    '',
                                                              ),
                                                            },
                                                        type:
                                                            CustomButtonType
                                                                .filled,
                                                        borderRadius: 5,
                                                        textColor:
                                                            _vendorsSelected
                                                                    .contains(
                                                                      entry
                                                                          .value,
                                                                    )
                                                                ? null
                                                                : Colors
                                                                    .grey
                                                                    .shade900,
                                                        backgroundColor:
                                                            _vendorsSelected
                                                                    .contains(
                                                                      entry
                                                                          .value,
                                                                    )
                                                                ? null
                                                                : Colors
                                                                    .grey
                                                                    .shade200,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (_productTypes.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Por tipo:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 10,
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children:
                                              _productTypes
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (entry) => Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 10,
                                                      ),
                                                      child: CustomButton(
                                                        label:
                                                            entry.value ?? '',
                                                        onPressed:
                                                            () => {
                                                              selectTypes(
                                                                entry.value ??
                                                                    '',
                                                              ),
                                                            },
                                                        type:
                                                            CustomButtonType
                                                                .filled,
                                                        borderRadius: 5,
                                                        textColor:
                                                            _productTypesSelected
                                                                    .contains(
                                                                      entry
                                                                          .value,
                                                                    )
                                                                ? null
                                                                : Colors
                                                                    .grey
                                                                    .shade900,
                                                        backgroundColor:
                                                            _productTypesSelected
                                                                    .contains(
                                                                      entry
                                                                          .value,
                                                                    )
                                                                ? null
                                                                : Colors
                                                                    .grey
                                                                    .shade200,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (_tags.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Por etiqueta:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 10,
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children:
                                              _tags
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (entry) => Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 10,
                                                      ),
                                                      child: CustomButton(
                                                        label:
                                                            entry.value ?? '',
                                                        onPressed:
                                                            () => {
                                                              selectTag(
                                                                entry.value ??
                                                                    '',
                                                              ),
                                                            },
                                                        type:
                                                            CustomButtonType
                                                                .filled,
                                                        borderRadius: 5,
                                                        textColor:
                                                            _tagsSelected
                                                                    .contains(
                                                                      entry
                                                                          .value,
                                                                    )
                                                                ? null
                                                                : Colors
                                                                    .grey
                                                                    .shade900,
                                                        backgroundColor:
                                                            _tagsSelected
                                                                    .contains(
                                                                      entry
                                                                          .value,
                                                                    )
                                                                ? null
                                                                : Colors
                                                                    .grey
                                                                    .shade200,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(
                                height: 20,
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : null,
              ),
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: CustomScrollView(
              physics: widget.physics,
              controller: widget.controller,
              slivers: [
                if (_filteredProductList.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = _filteredProductList[index];
                      return GestureDetector(
                        onTap: () => widget.handleOnTap(product),
                        child: SizedBox(
                          height: 230,
                          child: Material(
                            color: Colors.transparent,
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Column(
                                          spacing: 8,
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  product.getOnlyImages().first,
                                                  width: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),

                                            Text(
                                              '${product.getFlawors().isNotEmpty ? '${product.getFlawors().length} ${product.getFlawors().length > 1 ? 'Sabores' : 'Sabor'}' : ''} '
                                              '${product.getSizes(null).isNotEmpty ? '${product.getSizes(null).length} ${product.getSizes(null).length > 1 ? 'Tamaños' : 'Tamaño'}' : ''}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),

                                        // Positioned(
                                        //   top: 4,
                                        //   left: 4,
                                        //   child: Container(
                                        //     padding:
                                        //         const EdgeInsets.symmetric(
                                        //           horizontal: 6,
                                        //           vertical: 2,
                                        //         ),
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.orange,
                                        //       borderRadius:
                                        //           BorderRadius.circular(6),
                                        //     ),
                                        //     child: Text(
                                        //       'Nuevo',
                                        //       style: TextStyle(
                                        //         color: MyColors.textBtnColor,
                                        //         fontSize: 10,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              fontFamily: 'NeulisAlt',
                                              color: getTextColor(context),
                                            ),
                                          ),
                                          Text(
                                            product.description ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,

                                              fontFamily: 'Poppins',
                                              color: getTextColor(context),
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          // Price
                                          Row(
                                            children: [
                                              Text(
                                                '\$${product.getSelectedVariant()?.price ?? ''}',
                                                style: TextStyle(
                                                  color: MyColors.btnColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (product
                                                      .getSelectedVariant()
                                                      ?.compareAtPrice !=
                                                  null)
                                                Text(
                                                  '\$${product.getSelectedVariant()?.compareAtPrice ?? ''}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

                                          OptionOfferWidget(
                                            icon: 'assets/icons/ship_item.svg',
                                            title: "Envío: 1-3 días",
                                            colorFilter: Colors.grey.shade600,
                                          ),
                                          const SizedBox(height: 8),

                                          CustomButton(
                                            label:
                                                (product.totalInventory != 0 &&
                                                        (product
                                                                .getSelectedVariant()
                                                                ?.getStock() !=
                                                            0))
                                                    ? 'Añadir al carrito'
                                                    : 'Ver producto',
                                            boldText: true,
                                            onPressed:
                                                (product.totalInventory != 0 &&
                                                        (product
                                                                .getSelectedVariant()
                                                                ?.getStock() !=
                                                            0))
                                                    ? () => addToCart(
                                                      context: context,
                                                      loading: loading,
                                                      product: product,
                                                      count: 1,
                                                      goToConfirmCart:
                                                          !product
                                                              .isRecurring(),
                                                      showBottomDetail:
                                                          product.isRecurring(),
                                                      showPopup: false,
                                                      applyDiscount: false,
                                                    )
                                                    : () => widget.handleOnTap(
                                                      product,
                                                    ),
                                            type: CustomButtonType.outline,
                                            height: 40,
                                            borderRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: _filteredProductList.length),
                  ),
              ],
            ),
          ),
        ],
      ),
      // ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = MyColors.btnColor;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

