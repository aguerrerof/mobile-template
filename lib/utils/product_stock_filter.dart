import 'package:mobile_app_template/models/response_models.dart';

/// Filtros reutilizables para listas de [Product] según inventario.

extension ProductIterableStockExtension on Iterable<Product> {
  /// Solo productos cuya suma de stock de variantes es mayor que cero
  /// (o [Product.totalInventory] si no hay variantes).
  List<Product> whereInStock() =>
      where((Product p) => p.hasAvailableStock()).toList();
}

