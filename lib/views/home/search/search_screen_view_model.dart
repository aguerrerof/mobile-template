import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';

class SearchViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _text = '';
  String? _after;
  List<Product> _products = [];
  PageInfo? _pageInfo;

  bool get isLoading => _isLoading;
  String get text => _text;
  List<Product> get products => _products;
  PageInfo? get pageInfo => _pageInfo;

  void updateTextSearch(String text) {
    _text = text;
    notifyListeners();
  }

  void updateafter(String? after) {
    _after = after;
    notifyListeners();
  }

  Future<void> fetchProducts(bool clearList) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    if (clearList) {
      _products = [];
      _after = null;
      _pageInfo = null;
      notifyListeners();
    }
    try {
      final result = await ServicesAPI().getProductsFromText(_text, _after);

      if (result.success) {
        final products = result.data;
        if (products == null) {
          throw Exception('No se encontraron productos');
        }
        _products.addAll(products);
        _pageInfo = result.pageInfo;
        notifyListeners();
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al obtener los productos',
        );
      }
    } catch (e) {
      print("Error fetchProducts: $e");
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToProductDetail(BuildContext context, Product product) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/productDetail', arguments: product);
  }
}

