import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/product_stock_filter.dart';

class DetailCollectionViewModel extends ChangeNotifier {
  late List<Collection> _sections = [];
  late List<Product> _products = [];
  late String _title = '';
  bool _isLoading = false;
  bool _isProductLoading = false;
  String _errorString = '';
  Customer? user;
  String? _collectionId;
  Collection? _collection;
  PageInfo? _pageInfo;
  String? _after;

  List<Collection> get detailCollectionSections => _sections;
  List<Product> get listProducts => _products;
  bool get isLoading => _isLoading;
  bool get isProductLoading => _isProductLoading;
  String get errorString => _errorString;
  String get title => _title;
  Collection? get collection => _collection;
  PageInfo? get pageInfo => _pageInfo;

  void initValues() {
    _sections = [];
    _products = [];
    _errorString = '';
    _title = '';
    notifyListeners();
  }

  void updateDetailCollectionSections(List<Collection> list) {
    _sections = list;
    notifyListeners();
  }

  void updateProducts(List<Product> list) {
    _products.addAll(list);
    notifyListeners();
  }

  void updatePageInfo(PageInfo? page) {
    _pageInfo = page;
    notifyListeners();
  }

  void updateafter(String? after) {
    _after = after;
    notifyListeners();
  }

  void setCollectionId(String id) {
    _collectionId = id;
    notifyListeners();
  }

  void updateCollection(Collection collection) {
    _collection = collection;
    notifyListeners();
    updateTitle(
      collection.getDetailTitle() ??
          collection.getHeaderTitle() ??
          collection.title,
    );
  }

  void updateTitle(String title) {
    _title = title;
    notifyListeners();
  }

  Future<void> fetchCollection() async {
    _isLoading = true;
    _isProductLoading = true;
    _errorString = '';
    _products = [];
    updatePageInfo(null);
    notifyListeners();

    try {
      final id = _collectionId ?? _collection?.id;
      if (id == null) {
        throw Exception('No hay una categoria seleccionada');
      }

      final results = await Future.wait([
        ServicesAPI().getCollectionById(id, 2),
        ServicesAPI().getProductsCollection(id, _after),
      ]);

      final collectionResult = results[0] as GenericResult<Collection>;
      final productsResult = results[1] as GenericResult<List<Product>>;

      if (collectionResult.success && collectionResult.data != null) {
        final collection = collectionResult.data!;
        print('result collections: ${collectionResult.data}');
        updateCollection(collection);
        if (collection.metafields.isNotEmpty) {
          for (var metafield in collection.metafields) {
            if (metafield.key == 'subcategories') {
              updateDetailCollectionSections(metafield.value);
            }
          }
        }
      } else {
        throw Exception(
          collectionResult.errors.isNotEmpty
              ? 'Error message: ${collectionResult.errors[0].message}'
              : 'Error al obtener la colección',
        );
      }

      if (productsResult.success) {
        final products = (productsResult.data ?? []).whereInStock();
        print('result list products in collection: $products');
        updateProducts(products);
        updatePageInfo(productsResult.pageInfo);
        if (_collection != null && _collection!.metafields.isNotEmpty) {
          for (var metafield in _collection!.metafields) {
            if (metafield.key == 'subcategories') {
              updateDetailCollectionSections(metafield.value);
            }
          }
        }
      }
    } catch (e) {
      print("Error fetchCollection: $e");
      _errorString = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      _isProductLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    if (_isProductLoading) return;
    _isProductLoading = true;
    notifyListeners();

    try {
      if (_collectionId == null && _collection?.id == null) {
        throw Exception('No hay una categoria seleccionada');
      }
      final result = await ServicesAPI().getProductsCollection(
        _collectionId ?? _collection!.id,
        _after,
      );

      if (result.success) {
        print('result list products in collection: ${result.data}');
        final products = (result.data ?? []).whereInStock();

        updateProducts(products);
        updatePageInfo(result.pageInfo);
        if (_collection!.metafields.isNotEmpty) {
          for (var metafield in collection!.metafields) {
            if (metafield.key == 'subcategories') {
              updateDetailCollectionSections(metafield.value);
            }
          }
        }
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
      _isProductLoading = false;
      notifyListeners();
    }
  }

  void goToProductDetail(BuildContext context, Product product) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/productDetail', arguments: product);
  }

  Future<void> goToDetail(BuildContext context, Collection data) async {
    Navigator.of(context, rootNavigator: true).pushNamed(
      '/detailCollection',
      arguments: {"collection": data, "showBack": true},
    );
  }

  Future<void> goToPetHealth(BuildContext context) async {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/petHealth', arguments: {});
  }
}

