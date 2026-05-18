import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/image_slider.dart';
import 'package:mobile_app_template/components/product_card.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class GeneralSection extends StatefulWidget {
  final String title;
  final String description;
  final bool showMoreBtn;
  final List<String> imageUrls;
  final List<Collection> collection;
  final List<Product> products;
  final Function(dynamic) onTap;
  final Function() onTapSection;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final String? productParentId;

  const GeneralSection({
    super.key,
    required this.title,
    required this.description,
    this.showMoreBtn = false,
    this.imageUrls = const [],
    this.collection = const [],
    this.products = const [],
    required this.onTap,
    required this.onTapSection,
    this.backgroundColor,
    this.titleStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      fontFamily: 'NeulisAlt',
    ),
    this.productParentId,
  });

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  List<Product> _products = [];
  bool _isProductLoading = false;
  String? _after;

  @override
  void initState() {
    super.initState();
    if (widget.products.isEmpty && widget.productParentId != null) {
      fetchProducts();
    } else if (widget.products.isNotEmpty) {
      setState(() => _products = widget.products);
    }
  }

  Future<void> fetchProducts() async {
    if (_isProductLoading) return;
    setState(() => _isProductLoading = true);

    try {
      if (widget.productParentId == null) {
        throw Exception('No hay una categoria seleccionada');
      }

      final result = await ServicesAPI().getProductsCollection(
        widget.productParentId!,
        _after,
      );

      if (result.success) {
        print('result list products in collection: ${result.data}');

        setState(() {
          _products = result.data ?? [];
        });
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al obtener la colección',
        );
      }
    } catch (e) {
      print("Error fetchCollection: $e");
    } finally {
      if (mounted) {
        setState(() => _isProductLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.title.isNotEmpty)
                      Expanded(
                        child: Text(
                          widget.title,
                          style: widget.titleStyle,
                          maxLines: null,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    if (widget.showMoreBtn)
                      CustomButton(
                        label: "Ver todos",
                        onPressed: () => widget.onTapSection(),
                        type: CustomButtonType.text,
                        textColor: MyColors.secondary,
                      ),
                  ],
                ),
                if (widget.description.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'NeulisAlt',
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (widget.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ImageSlider(imageUrls: widget.imageUrls),
          ],
          const SizedBox(height: 10),
          _isProductLoading
              ? Padding(
                padding: EdgeInsetsGeometry.only(top: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                    strokeWidth: 1.5,
                  ),
                ),
              )
              : _products.isNotEmpty
              ? SizedBox(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: GestureDetector(
                        onTap: () => widget.onTap(product),
                        child: ProductCard(
                          imageUrl: product.getOnlyImages().first,
                          price: product.getSelectedVariant()?.price ?? '',
                          rating: 0.0,
                          title: product.title,
                          reviewCount: 0,
                          isPrescription: true,
                          subtitle: product.description ?? '',
                          originalPrice:
                              product.getSelectedVariant()?.compareAtPrice,
                          textDiscountBadge: "",
                        ),
                      ),
                    );
                  },
                ),
              )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

