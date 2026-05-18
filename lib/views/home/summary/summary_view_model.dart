import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';

enum PaymentType { creditDebit, paypal }

class SumaryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  ShopifyOrder? _order;
  List<ShopifyLineItem> _products = [];

  bool get isLoading => _isLoading;
  ShopifyOrder? get order => _order;
  List<ShopifyLineItem> get products => _products;

  void updateOrder(ShopifyOrder order) {
    _order = order;
    _products = _order?.lineItems ?? [];
    getProducts();
    notifyListeners();
  }

  void getProducts() async {
    final productIds =
        _order?.lineItems
            .map((item) => 'gid://shopify/Product/${item.productId}')
            .toSet()
            .toList();
    if (productIds != null) {
      final result = await ServicesAPI().getProductsByIds(productIds);
      if (result.success) {
        final products = result.data;
        if (products == null) {
          throw Exception('No se encontraron productos');
        }

        for (var item in _order?.lineItems ?? []) {
          Product? matchingProduct;
          try {
            matchingProduct = products.firstWhere(
              (product) =>
                  product.id == 'gid://shopify/Product/${item.productId}',
            );
          } catch (e) {
            matchingProduct = null;
          }

          if (matchingProduct != null) {
            item.title = matchingProduct.title;
            item.image =
                matchingProduct.getOnlyImages().isNotEmpty
                    ? matchingProduct.getOnlyImages().first
                    : null;
          }
        }
        notifyListeners();
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al obtener los productos',
        );
      }
    }
  }
}

