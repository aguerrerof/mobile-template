import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:provider/provider.dart';

class OrderDetailViewModel extends ChangeNotifier {
  bool _isLoading = false;

  String _userName = '';
  Order? _order;
  CardDetail? _payment;
  String? _messageError;
  bool _showTrakingDetail = false;
  bool _goBack = false;

  bool _showDeleteDialog = false;

  bool get isLoading => _isLoading;
  Order? get order => _order;
  String get userName => _userName;
  String? get messageError => _messageError;
  bool get showDeleteDialog => _showDeleteDialog;
  CardDetail? get payment => _payment;
  bool get showTrakingDetail => _showTrakingDetail;
  bool get goBack => _goBack;

  void updateOrder(Order? order) {
    _order = order;
    _payment = order?.card;
    // getProducts();
    notifyListeners();
  }

  void updateMessage(String? message) {
    _messageError = message;
    notifyListeners();
  }

  void updateDeleteDialogStatus(bool status) {
    _showDeleteDialog = status;
    notifyListeners();
  }

  void updateShowTrackingDetail(bool value) {
    _showTrakingDetail = value;
    notifyListeners();
  }

  void updateCard(CardDetail card) async {
    _isLoading = true;
    notifyListeners();

    final result = await ServicesAPI().updatePaymentOrder(order!, card.id);
    if (result.success) {
      _order = result.data;
      _payment = order?.card;
    }
    _isLoading = false;
    notifyListeners();
  }

  void getProducts() async {
    final productIds =
        _order?.order?.lineItems
            .map((item) => 'gid://shopify/Product/${item.productId}')
            .toList();
    if (productIds != null) {
      final result = await ServicesAPI().getProductsByIds(productIds);
      if (result.success) {
        final products = result.data;
        if (products == null) {
          throw Exception('No se encontraron productos');
        }

        for (var item in _order?.order?.lineItems ?? []) {
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

  void retryPayment() async {
    _isLoading = true;
    notifyListeners();
    final result = await ServicesAPI().retryPayment(_order?.id ?? "");
    if (result.success) {
      _goBack = true;
    } else {
      final msg =
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al reintentar el pago';
      updateMessage(msg);
    }

    _isLoading = false;
    notifyListeners();
  }
}

