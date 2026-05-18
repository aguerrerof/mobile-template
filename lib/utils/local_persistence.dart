import 'package:mobile_app_template/models/response_models.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> saveItem(CartItem item) async {
  final box = Hive.box('cart');
  await box.put(item.variantId, item.toJson());
}

List<CartItem> getItems() {
  final box = Hive.box('cart');
  final items = box.values.toList();
  return items.map((item) {
    final map = Map<String, dynamic>.from(item);
    return CartItem.fromJson(map);
  }).toList();
}

Future<void> deleteItem(String id) async {
  final box = Hive.box('cart');
  await box.delete(id);
}

Future<void> deleteCart() async {
  var box = await Hive.openBox('cart');
  await box.clear();
}

Future<void> saveRecurrenceFrequencies(List<Frequency> items) async {
  final box = Hive.box('recurrenceFrequency');
  await box.clear();
  for (final item in items) {
    await box.put(item.value, item.toJson());
  }
}

List<Frequency> getRecurrenceFrequency() {
  final box = Hive.box('recurrenceFrequency');
  final items = box.values.toList();
  return items.map((item) {
    final map = Map<String, dynamic>.from(item);
    return Frequency.fromJson(map);
  }).toList();
}

