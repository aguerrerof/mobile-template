import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

class DiscoverViewModel extends ChangeNotifier {
  late List<Collection> _sections = [];
  bool _isLoading = false;
  String _errorString = '';
  Customer? user;

  List<Collection> get discoverSections => _sections;
  bool get isLoading => _isLoading;
  String get errorString => _errorString;

  void setError(String error) {
    _errorString = error;
    notifyListeners();
  }

  void updateDiscoverSections(List<Collection> list) async {
    list.sort((a, b) => a.getOrder().compareTo(b.getOrder()));
    _sections = list;
    notifyListeners();
  }

  Future<void> fetchUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        user = Customer.fromJson({
          "firstName": currentUser.displayName,
          "email": currentUser.email,
        });
      }

      notifyListeners();
    } catch (e) {
      print("Error inesperado: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHomePageCollection() async {
    _isLoading = true;
    _errorString = '';
    notifyListeners();

    try {
      final result = await ServicesAPI().getCollectionById(null, 2);

      if (result.success) {
        print('result collections: ${result.data}');
        final collection = result.data;
        if (collection == null) {
          throw Exception('No se encontró la colección home');
        }

        if (collection.metafields.isNotEmpty) {
          for (var metafield in collection.metafields) {
            if (metafield.key == 'subcategories') {
              updateDiscoverSections(metafield.value);
            }
          }
        }
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al obtener el la categoria Home',
        );
      }
    } catch (e) {
      print("Error fetchHomePageCollection: $e");
      _errorString = getFriendlyErrorMessage(e.toString());
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToDetail(BuildContext context, Collection data) async {
    AnalyticsService().trackEvent("User click ${data.title}");
    Navigator.of(context, rootNavigator: true).pushNamed(
      '/detailCollection',
      arguments: {"collection": data, "showBack": true},
    );
  }

  void goToProductDetail(BuildContext context, Product product) {
    AnalyticsService().trackEvent("User click ${product.title}");
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/productDetail', arguments: product);
  }
}

