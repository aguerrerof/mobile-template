import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:mobile_app_template/components/vertical_steeper_widget.dart';

class AuthResult {
  final bool success;
  final List<CustomerUserError> errors;

  AuthResult({required this.success, this.errors = const []});
}

class CustomerUserError {
  final String code;
  final String message;
  final List<String> field;

  CustomerUserError({
    required this.code,
    required this.message,
    required this.field,
  });

  factory CustomerUserError.fromJson(Map<String, dynamic> json) {
    return CustomerUserError(
      code: json['code'] ?? 'UNKNOWN',
      message: json['message'] ?? 'An unknown error occurred',
      field: (json['field'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class GenericError {
  final String code;
  final String message;

  GenericError({required this.code, required this.message});

  factory GenericError.fromJson(Map<String, dynamic> json) {
    return GenericError(
      code: json['code'] ?? 'UNKNOWN',
      message: json['message'] ?? 'An unknown error occurred',
    );
  }
}

class CollectionResult {
  final bool success;
  final List<Collection> collections;
  final List<GenericError> errors;

  CollectionResult({
    required this.success,
    this.collections = const [],
    this.errors = const [],
  });
}

class PageInfo {
  final bool? hasNextPage;
  final String? endCursor;
  final int? current;
  final int? last;
  final int? perPage;
  final int? total;

  PageInfo({
    this.hasNextPage,
    this.endCursor,
    this.current,
    this.last,
    this.perPage,
    this.total,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      hasNextPage: json['hasNextPage'] ?? false,
      endCursor: json['endCursor'] ?? '',
      current: json['current_page'] ?? 1,
      last: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  bool hasNext() {
    if (current != null && last != null) return current! < last!;
    return false;
  }

  int nextPage() {
    if (current != null && last != null) {
      return (current! + 1) > last! ? last! : (current! + 1);
    }
    return 1;
  }
}

class GenericResult<T> {
  final bool success;
  final T? data;
  final List<GenericError> errors;
  final PageInfo? pageInfo;
  final String? message;

  GenericResult({
    required this.success,
    this.message,
    this.data,
    this.errors = const [],
    this.pageInfo,
  });

  factory GenericResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final dataJson = json['data'];

    PageInfo? pageInfo;
    if (json['pageInfo'] is Map<String, dynamic>) {
      pageInfo = PageInfo.fromJson(json['pageInfo']);
    } else {
      if (dataJson is Map<String, dynamic> &&
          dataJson['pageInfo'] is Map<String, dynamic>) {
        pageInfo = PageInfo.fromJson(dataJson['pageInfo']);
      } else {
        pageInfo = null;
      }
    }

    var messageUserError = '';
    if (dataJson is Map<String, dynamic> &&
        dataJson['userErrors'] is List &&
        dataJson['userErrors'].isNotEmpty) {
      messageUserError =
          dataJson['userErrors'].first['message']?.toString() ?? '';
    } else {
      messageUserError = '';
    }

    final errorMessage = json['error']?.toString() ?? messageUserError;
    final devErrorMessage = json['devError']?.toString() ?? messageUserError;

    final error = GenericError(code: '', message: errorMessage);
    final devError = GenericError(code: '', message: devErrorMessage);

    final message = json['message']?.toString();

    return GenericResult(
      success:
          ((dataJson != null || message != null) && messageUserError == ''),
      data: dataJson != null && fromJsonT != null ? fromJsonT(dataJson) : null,
      errors: [error, devError],
      pageInfo: pageInfo,
      message: message,
    );
  }

  String? getError() {
    if (errors.isNotEmpty) {
      return errors.first.message;
    } else {
      return null;
    }
  }

  String getDevError() {
    if (errors.isNotEmpty) {
      return errors[1].message;
    } else {
      return '';
    }
  }
}

class Metafield {
  final String namespace;
  final String key;
  final dynamic value;
  final String? inferredType;

  Metafield({
    required this.namespace,
    required this.key,
    this.value,
    this.inferredType,
  });

  factory Metafield.fromJson(Map<String, dynamic> json) {
    final namespace = json['namespace']?.toString() ?? '';
    final key = json['key']?.toString() ?? '';
    var value = json['value'];
    final inferredType = json['inferredType']?.toString() ?? '';

    if (key == 'subcategories') {
      final newValue =
          (value as List<dynamic>? ?? [])
              .map((item) {
                if (item is Map<String, dynamic>) {
                  final collection = item as Map<String, dynamic>?;
                  if (collection == null) return null;
                  return Collection.fromJson(collection);
                } else {
                  return value;
                }
              })
              .whereType<Collection>()
              .toList();
      value = newValue;
    }

    return Metafield(
      namespace: namespace,
      key: key,
      value: value,
      inferredType: inferredType,
    );
  }
}

class Collection {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<Product> products;
  final List<Metafield> metafields;

  Collection({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.products = const [],
    this.metafields = const [],
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['imageUrl']?.toString();

    final productsData = json['products'] as List<dynamic>? ?? [];
    final products =
        productsData
            .map((edge) {
              final node = edge['node'] as Map<String, dynamic>?;
              if (node == null) return null;
              return Product.fromJson(node);
            })
            .whereType<Product>()
            .toList();

    final metafieldsData = json['metafields'] as List<dynamic>? ?? [];
    final metafields =
        metafieldsData
            .map((metafield) {
              if (metafield is! Map<String, dynamic>) return null;
              return Metafield.fromJson(metafield);
            })
            .whereType<Metafield>()
            .toList();

    return Collection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: imageUrl,
      products: products,
      metafields: metafields,
    );
  }

  String? getType() {
    if (metafields.isNotEmpty) {
      String? type = '';
      for (var metafield in metafields) {
        if (metafield.key == 'type_section') {
          type = metafield.value.toString();
        }
      }
      if (type == '') {
        return null;
      }
      return type;
    }
    return null;
  }

  String? getSubcategoryType() {
    if (metafields.isNotEmpty) {
      String? type = '';
      for (var metafield in metafields) {
        if (metafield.key == 'subcategory_style') {
          type = metafield.value.toString();
        }
      }
      if (type == '') {
        return null;
      }
      return type;
    }
    return null;
  }

  String? getImageMetafield() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'collectionimage') {
          if (metafield.value is! Map<String, dynamic>) return null;
          return metafield.value['image']?['url'] as String;
        }
      }
    }
    return null;
  }

  String? getHeaderImageMetafield() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'image_header') {
          if (metafield.value is! Map<String, dynamic>) return null;
          return metafield.value['image']?['url'] as String;
        }
      }
    }
    return null;
  }

  String? getBackgroundColor() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'background') {
          return metafield.value.toString();
        }
      }
    }
    return null;
  }

  bool? isPrincipal() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'is_principal') {
          return metafield.value.toLowerCase() == 'true' ||
              metafield.value == '1';
        }
      }
    }
    return false;
  }

  List<String> getImages() {
    if (metafields.isNotEmpty) {
      List<String> list = [];
      for (var metafield in metafields) {
        if (metafield.key == 'image_list') {
          list =
              metafield.value
                  .map((metafield) {
                    if (metafield is! Map<String, dynamic>) return null;
                    return metafield['image']?['url'] as String;
                  })
                  .whereType<String>()
                  .toList();
        }
      }
      return list;
    }
    return [];
  }

  List<Collection> getSubcategories() {
    if (metafields.isNotEmpty) {
      List<Collection> list = [];
      for (var metafield in metafields) {
        if (metafield.key == 'subcategories') {
          list = metafield.value;
        }
      }
      return list;
    }
    return [];
  }

  int getOrder() {
    if (metafields.isNotEmpty) {
      int order = 0;
      for (var metafield in metafields) {
        if (metafield.key == 'order') {
          order = int.parse(metafield.value);
        }
      }
      return order;
    }
    return 0;
  }

  String? getHeaderTitle() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'header_title') {
          return metafield.value;
        }
      }
    }
    return null;
  }

  String? getServiceName() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'service_name') {
          return metafield.value;
        }
      }
    }
    return null;
  }

  String? getDetailTitle() {
    if (metafields.isNotEmpty) {
      for (var metafield in metafields) {
        if (metafield.key == 'detail_title') {
          return metafield.value;
        }
      }
    }
    return null;
  }
}

class Product {
  final String id;
  final String title;
  final String? description;
  List<ProductVariant> variants;
  final List<MediaItem> media;
  ProductVariant? selectedVariant;
  final String? productType;
  final String? vendor;
  final List<String> tags;
  final Map<String, String> metafields;
  final int totalInventory;
  final List<ProductVariant> purchased;

  Product({
    required this.id,
    required this.title,
    this.description,
    this.variants = const [],
    this.media = const [],
    this.selectedVariant,
    this.productType,
    this.vendor,
    this.tags = const [],
    this.metafields = const {},
    this.totalInventory = 0,
    this.purchased = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final purchasedList =
        (json['variants']?['purchased'] as List<dynamic>? ?? [])
            .map(
              (variant) =>
                  ProductVariant.fromJson(variant as Map<String, dynamic>),
            )
            .whereType<ProductVariant>()
            .toList();
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      productType: json['productType']?.toString(),
      vendor: json['vendor']?.toString(),
      totalInventory: json['totalInventory'] ?? 1,
      tags:
          (json['tags'] as List<dynamic>? ?? [])
              .map((tag) => tag)
              .whereType<String>()
              .toList(),
      variants:
          (json['variants']?['edges'] as List<dynamic>? ?? [])
              .map(
                (edge) => ProductVariant.fromJson(
                  edge['node'] as Map<String, dynamic>,
                ),
              )
              .whereType<ProductVariant>()
              .toList(),
      media:
          (json['media']?['edges'] as List<dynamic>? ?? [])
              .map(
                (edge) =>
                    MediaItem.fromJson(edge['node'] as Map<String, dynamic>),
              )
              .whereType<MediaItem>()
              .toList(),
      metafields: _parseMetafields(json['metafields']),
      purchased: purchasedList,
    );
  }

  static Map<String, String> _parseMetafields(dynamic metafieldsJson) {
    if (metafieldsJson == null || metafieldsJson['edges'] == null) return {};

    final List edges = metafieldsJson['edges'];
    return {
      for (final edge in edges)
        if (edge['node'] != null &&
            edge['node']['key'] != null &&
            edge['node']['value'] != null)
          edge['node']['key']: edge['node']['value'].toString(),
    };
  }

  List<String> getOnlyImages() {
    if (media.isNotEmpty) {
      List<String> list = [];
      for (var item in media) {
        if (item.image?.url.isNotEmpty ?? false) {
          list.add(item.image!.url);
        }
      }
      return list;
    }
    return [];
  }

  ProductVariant? getSelectedVariant() {
    if (selectedVariant == null) {
      return variants.first;
    }
    return selectedVariant;
  }

  String? getVariantFlavorOfSelectedVariant() {
    if (selectedVariant == null) {
      return variants.first.selectedOptions
          .map((option) => option.name == 'Sabor' ? option.value : '')
          .firstWhere((value) => value != '');
    }
    return selectedVariant!.selectedOptions
        .map((option) => option.name == 'Sabor' ? option.value : '')
        .firstWhere((value) => value != '');
  }

  void setVariantList(List<ProductVariant> list) {
    variants = list;
  }

  void setVariantSelected(ProductVariant item) {
    selectedVariant = item;
  }

  List<String?> getFlawors() {
    final flavors =
        variants
            .where(
              (variant) => variant.selectedOptions.any(
                (option) => option.name == 'Sabor',
              ),
            )
            .toList();
    if (flavors.isNotEmpty) {
      final newFlavors =
          flavors
              .map((variant) {
                final flavorOption = variant.selectedOptions.firstWhere(
                  (option) => option.name == 'Sabor',
                  orElse: () => GenericModel(name: '', value: ''),
                );
                return flavorOption.value ?? '';
              })
              .where((value) => value.isNotEmpty)
              .toSet()
              .toList();
      return newFlavors;
    }
    return [];
  }

  List<ProductVariant?> getSizes(String? selectedFlawor) {
    if (selectedFlawor == null) {
      return variants;
    }

    final sizes =
        variants
            .where((variant) {
              return variant.selectedOptions.any(
                (option) =>
                    option.name == 'Sabor' && option.value == selectedFlawor,
              );
            })
            .toSet()
            .toList();
    return sizes;
  }

  bool isRecurring() {
    return metafields['is_recurring'] == "true";
  }

  /// Hay inventario si la suma del stock de todas las variantes es mayor que cero,
  /// o si no hay variantes y [totalInventory] es mayor que cero.
  bool hasAvailableStock() {
    if (variants.isNotEmpty) {
      final total = variants.fold<int>(
        0,
        (accumulated, variant) => accumulated + variant.getStock(),
      );
      return total > 0;
    }
    return totalInventory > 0;
  }
}

class ProductVariant {
  final String id;
  final String? price;
  final String? compareAtPrice;
  final List<GenericModel> selectedOptions;
  final bool? taxable;
  final String? image;
  final int? inventoryQuantity;
  final InventoryItem? inventoryItem;
  final OfferRecurrence? discount;

  ProductVariant({
    required this.id,
    this.price,
    this.compareAtPrice,
    this.selectedOptions = const [],
    this.taxable,
    this.image,
    this.inventoryQuantity,
    this.inventoryItem,
    this.discount,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final taxable = json['taxable'] ?? true;
    final discount = json['discount'] as Map<String, dynamic>?;
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      price: json['price']?.toString(),
      compareAtPrice: json['compareAtPrice']?.toString(),
      taxable: taxable,
      inventoryQuantity: json['inventoryQuantity'] ?? json['total_stock'],
      selectedOptions:
          (json['selectedOptions'] as List<dynamic>? ?? [])
              .map(
                (option) =>
                    GenericModel.fromJson(option as Map<String, dynamic>),
              )
              .whereType<GenericModel>()
              .toList(),
      image: json['image']?['url']?.toString() ?? '',
      inventoryItem:
          json['inventoryItem'] is Map<String, dynamic>
              ? InventoryItem.fromJson(
                json['inventoryItem'] as Map<String, dynamic>,
              )
              : null,
      discount: discount != null ? OfferRecurrence.fromJson(discount) : null,
    );
  }

  String? getFlavorValue() {
    return selectedOptions
        .firstWhereOrNull((option) => option.name == 'Sabor')
        ?.value;
  }

  String? getSizeValue() {
    return selectedOptions
        .firstWhereOrNull((option) => option.name == 'Tamaño')
        ?.value;
  }

  int getStock() {
    return inventoryQuantity ?? inventoryItem?.totalStock ?? 0;
  }

  String getPriceRecurrencing() {
    final porcentaje = double.tryParse(discount?.discountValue ?? '') ?? 0.0;
    return (double.tryParse(price ?? '0.0')! * (1 - (porcentaje * (-1) / 100)))
        .toStringAsFixed(2);
  }
}

class InventoryItem {
  final String id;
  final List<InventoryLevel> levels;

  InventoryItem({required this.id, required this.levels});

  int get totalStock => levels.fold(0, (sum, l) => sum + l.available);

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final edges = json['inventoryLevels']?['edges'] as List? ?? [];
    final levels =
        edges.map((e) => InventoryLevel.fromJson(e['node'])).toList();

    return InventoryItem(id: json['id'], levels: levels);
  }
}

class InventoryLevel {
  final String locationName;
  final int available;

  InventoryLevel({required this.locationName, required this.available});

  factory InventoryLevel.fromJson(Map<String, dynamic> json) {
    final location = json['location']?['name'] ?? '';
    final quantities = json['quantities'] as List? ?? [];
    final available =
        quantities.firstWhere(
          (q) => q['name'] == 'available',
          orElse: () => {'quantity': 0},
        )['quantity'];

    return InventoryLevel(locationName: location, available: available);
  }
}

class GenericModel {
  final String name;
  final String? value;

  GenericModel({required this.name, this.value});

  factory GenericModel.fromJson(Map<String, dynamic> json) {
    return GenericModel(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString(),
    );
  }
}

class Imageshop {
  final String url;
  final String? altText;

  Imageshop({required this.url, this.altText});

  factory Imageshop.fromJson(Map<String, dynamic> json) {
    return Imageshop(
      url: json['url']?.toString() ?? '',
      altText: json['altText']?.toString(),
    );
  }
}

class MediaItem {
  final String? mediaContentType;
  final String? alt;
  final String? embeddedUrl;
  final String? host;
  final Imageshop? image;

  MediaItem({
    required this.mediaContentType,
    this.alt,
    this.embeddedUrl,
    this.host,
    this.image,
  });
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      mediaContentType: json['mediaContentType']?.toString(),
      alt: json['alt']?.toString(),
      embeddedUrl: json['embeddedUrl']?.toString(),
      host: json['host']?.toString(),
      image:
          json['image'] != null
              ? Imageshop.fromJson(json['image'] as Map<String, dynamic>)
              : null,
    );
  }

  bool isImage() {
    return mediaContentType == 'IMAGE';
  }

  bool isYoutubeVideo() {
    return mediaContentType == 'EXTERNAL_VIDEO' && host == 'YOUTUBE';
  }
}

class Customer {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final Address? defaultAddress;
  final List<OrderEdge> orders;
  final bool canReactivate;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.defaultAddress,
    this.orders = const [],
    this.canReactivate = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email:
          json['email']?.toString() ??
          json['emailAddress']?['emailAddress']?.toString() ??
          json['defaultEmailAddress']?['emailAddress']?.toString(),
      phone: json['phone']?.toString(),
      defaultAddress:
          json['defaultAddress'] != null
              ? Address.fromJson(json['defaultAddress'] as Map<String, dynamic>)
              : null,
      orders:
          (json['orders']?['edges'] as List<dynamic>? ?? [])
              .map((edge) => OrderEdge.fromJson(edge as Map<String, dynamic>))
              .whereType<OrderEdge>()
              .toList(),
      canReactivate: json['can_reactivate'] ?? false,
    );
  }

  String getName() {
    return firstName?.split(' ').first ?? '';
  }
}

class Address {
  final String? id;
  final String? firstName;
  final String? address1;
  final String? address2;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? name;
  final String? countryCode;
  bool isDefault;

  Address({
    this.id,
    this.firstName,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.phone,
    this.name,
    this.isDefault = false,
    this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString();
    // final id = rawId != null && rawId.contains('?')
    //     ? rawId.split('?').first
    //     : rawId;
    return Address(
      id: rawId,
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      address1: json['address1']?.toString(),
      address2: json['address2']?.toString(),
      city: json['city']?.toString(),
      province: json['provinceCode']?.toString(),
      postalCode: json['postalCode'] ?? json['zip'],
      country: json['country']?.toString(),
      countryCode: json['countryCode']?.toString(),
      phone: json['phone']?.toString(),
      name: json['name'].toString(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'address_line_1': address1,
      'address_line_2': address2,
      'city': city,
      'province_code': province ?? ' ',
      'postal_code': postalCode,
      'country_code': countryCode ?? 'EC',
      'phone': phone,
      'default': isDefault,
    };
  }

  Map<String, dynamic> toJsonOrder() {
    return {
      'first_name': firstName,
      'last_name': '.',
      'address1': address1,
      'address2': address2,
      'city': city ?? 'Guayaquil',
      'province': province ?? 'Guayas',
      'zip': postalCode ?? '',
      'country': country ?? 'Ecuador',
      'phone': phone,
    };
  }
}

class ShopifyOrder {
  final int id;
  final String orderNumber;
  final String name;
  final String email;
  final double totalPrice;
  final String currency;
  final String financialStatus;
  final String orderStatusUrl;
  final String createdAt;
  final Address? shippingAddress;
  final List<ShopifyLineItem> lineItems;
  final String? subtotalPrice;
  final String? totalTax;
  final String? totalShippingPrice;
  final String? paymentInfo;
  final List<String>? recurrencingIds;

  ShopifyOrder({
    required this.id,
    required this.orderNumber,
    required this.name,
    required this.email,
    required this.totalPrice,
    required this.currency,
    required this.financialStatus,
    required this.orderStatusUrl,
    required this.createdAt,
    this.shippingAddress,
    required this.lineItems,
    this.subtotalPrice,
    this.totalTax,
    this.totalShippingPrice,
    this.paymentInfo,
    this.recurrencingIds,
  });

  factory ShopifyOrder.fromJson(Map<String, dynamic> json) {
    return ShopifyOrder(
      id: json['id'],
      orderNumber: json['order_number'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      totalPrice: double.parse(json['current_total_price'].toString()),
      currency: json['currency'].toString(),
      financialStatus: json['financial_status'].toString(),
      orderStatusUrl: json['order_status_url'].toString(),
      createdAt: json['created_at'].toString(),
      shippingAddress:
          json['shipping_address'] != null
              ? Address.fromJson(json['shipping_address'])
              : null,
      lineItems:
          (json['line_items'] as List<dynamic>)
              .map((item) => ShopifyLineItem.fromJson(item))
              .toList(),
      subtotalPrice: json['current_subtotal_price'].toString(),
      totalTax: json['current_total_tax'].toString(),
      totalShippingPrice:
          json["total_shipping_price_set"]?['shop_money']?["amount"]
              .toString() ??
          '0.0',
      paymentInfo: json["payment_info"],
      recurrencingIds: json['recurring_ids'].toString().split(','),
    );
  }
}

class ShopifyLineItem {
  final int id;
  String title;
  int quantity;
  final double price;
  final String variantTitle;
  final String productId;
  final String? vendor;
  final String? variantId;
  String? image;

  final bool? requiresShipping;
  final bool? taxable;

  ShopifyLineItem({
    this.id = 0,
    this.title = '',
    required this.quantity,
    required this.price,
    this.variantTitle = '',
    this.productId = '',
    this.variantId,
    this.vendor,
    this.image,
    this.requiresShipping,
    this.taxable,
  });

  factory ShopifyLineItem.fromJson(Map<String, dynamic> json) {
    return ShopifyLineItem(
      id: json['id'] ?? 0,
      title: json['title'].toString(),
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      variantTitle: json['variant_title'].toString(),
      productId: json['product_id'].toString(),
      vendor: json['vendor'].toString(),
      variantId: json['variant_id'].toString(),
      image: json['imageUrl'].toString(),
      requiresShipping: json['requiresShipping'],
      taxable: json['taxable'],
    );
  }

  Map<String, dynamic> toJsonFirestore() {
    return {
      'title': title,
      'imageUrl': image,
      'price': price,
      'quantity': quantity,
      'variant_id': variantId,
      'requiresShipping': requiresShipping,
      'taxable': taxable,
    };
  }
}

class OrderEdge {
  final ShopifyOrder node;

  OrderEdge({required this.node});

  factory OrderEdge.fromJson(Map<String, dynamic> json) {
    return OrderEdge(
      node: ShopifyOrder.fromJson(json['node'] as Map<String, dynamic>),
    );
  }
}

class CartItem {
  final int id;
  final String title;
  final String imageUrl;
  final double price;
  final String deliveryDate;
  final String variantId;
  final String? flavor;
  final String? size;
  int quantity;
  final double? itemSubotal;
  final double? tax;
  bool? isRecurrence;
  final Discount? appliedDiscount;
  String? frequency;
  bool? applyTax;
  bool applyDiscount;
  int stock;
  bool availableRecurrence;

  CartItem({
    this.id = 0,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.deliveryDate,
    required this.variantId,
    this.flavor,
    this.size,
    this.quantity = 1,
    this.itemSubotal,
    this.tax,
    this.isRecurrence,
    this.appliedDiscount,
    this.frequency,
    this.applyTax,
    required this.applyDiscount,
    this.stock = 0,
    this.availableRecurrence = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'deliveryDate': deliveryDate,
      'quantity': quantity,
      'variantId': variantId,
      'flavor': flavor,
      'size': size,
      'isRecurrence': isRecurrence,
      'frequency': frequency,
      'apply_tax': applyTax,
      'apply_discount': applyDiscount,
      'stock': stock,
      'available_recurrence': availableRecurrence,
    };
  }

  Map<String, dynamic> toCartJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'variant_id': variantId,
      'flavor': flavor,
      'size': size,
      'apply_tax': applyTax,
      'is_recurrence': isRecurrence,
      'frequency': frequency,
      'apply_discount': applyDiscount,
      'available_recurrence': availableRecurrence,
    };
  }

  Map<String, dynamic> toJsonRecurrence() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'variantId': variantId,
      'taxable': applyTax,
      'applyTax': applyTax,
      'applyDiscount': applyDiscount,
      'requiresShipping': true,
      'available_recurrence': availableRecurrence,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 0;
    final title = json['title']?.toString() ?? '';
    final imageUrl = (json['image_url'] ?? json['imageUrl'])?.toString() ?? '';
    final price = double.parse(json['price'].toString());
    final quantity = int.parse(json['quantity'].toString().split('.').first);
    final variantId =
        (json['variant_id'] ?? json['variantId'])?.toString() ?? '';
    final flavor = json['flavor']?.toString() ?? '';
    final size = json['size']?.toString() ?? '';
    final tax = double.parse(json['tax']?.toString() ?? '0.0');
    final isRecurrence = json['is_recurrence'] ?? json['isRecurrence'] ?? false;
    final frequency = json['frequency'].toString();
    final applyTax = json['apply_tax'] ?? json['applyTax'] ?? json['taxable'];
    final applyDiscount =
        json['apply_discount'] ?? json['applyDiscount'] ?? false;
    final deliveryDate = json['deliveryDate']?.toString() ?? '';
    final itemSubotal = double.parse(json['subtotal']?.toString() ?? '0.0');
    final appliedDiscount =
        json['appliedDiscount'] != null &&
                json['appliedDiscount'] is Map<String, dynamic>
            ? Discount.fromJson(json['appliedDiscount'] as Map<String, dynamic>)
            : null;
    final stock = json['stock'] ?? 0;
    final availableRecurrence = json['available_recurrence'] ?? false;

    return CartItem(
      id: id,
      title: title,
      imageUrl: imageUrl,
      price: price,
      deliveryDate: deliveryDate,
      quantity: quantity,
      variantId: variantId,
      flavor: flavor,
      size: size,
      itemSubotal: itemSubotal,
      tax: tax,
      isRecurrence: isRecurrence,
      appliedDiscount: appliedDiscount,
      frequency: frequency,
      applyTax: applyTax,
      applyDiscount: applyDiscount,
      stock: stock,
      availableRecurrence: availableRecurrence,
    );
  }
}

class Discount {
  final String code;
  final String title;
  final String value;
  final String valueType;
  final String ruleId;
  final String amount;
  final String totalAmount;

  Discount({
    this.code = '',
    this.title = '',
    this.value = '',
    this.valueType = '',
    this.ruleId = '',
    this.amount = '',
    this.totalAmount = '',
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    final code = json['description']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    final value = json['value']?.toString() ?? '';
    final valueType = json['prvalue_typeice'].toString();
    final ruleId = json['ruleId'].toString();
    final amount = json['amount']?.toString() ?? '';
    final totalAmount = json['total_amount']?.toString() ?? '';

    return Discount(
      code: code,
      title: title,
      value: value,
      valueType: valueType,
      ruleId: ruleId,
      amount: amount,
      totalAmount: totalAmount,
    );
  }
}

class CheckoutModel {
  final List<CartItem> items;
  final int? totalQuantity;
  final double? subtotal;
  final double? subtotal0;
  final double? subtotalIVA;
  final double? discount;
  final double? subtotalWithDiscount;
  final double? totaTax;
  final double? deliveryCost;
  final double? total;

  CheckoutModel({
    this.items = const [],
    this.totalQuantity,
    this.subtotal,
    this.subtotal0,
    this.subtotalIVA,
    this.discount,
    this.subtotalWithDiscount,
    this.totaTax,
    this.deliveryCost,
    this.total,
  });

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    final cartItems =
        (json['items'] as List<dynamic>? ?? [])
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .whereType<CartItem>()
            .toList();

    final totalQuantity = int.tryParse(json['totalQuantity'].toString()) ?? 0;
    final subtotal = double.tryParse(json['subtotal'].toString()) ?? 0.0;
    final subtotal0 = double.tryParse(json['subtotal0'].toString()) ?? 0.0;
    final subtotalIVA = double.tryParse(json['subtotalIVA'].toString()) ?? 0.0;
    final discount = double.tryParse(json['discount'].toString()) ?? 0.0;

    final subtotalWithDiscount =
        double.tryParse(json['subtotalWithDiscount'].toString()) ?? 0.0;
    final totaTax = double.tryParse(json['totalTax'].toString()) ?? 0.0;
    final deliveryCost =
        double.tryParse(json['deliveryCost'].toString()) ?? 0.0;
    final total = double.tryParse(json['total'].toString()) ?? 0.0;

    return CheckoutModel(
      items: cartItems,
      totalQuantity: totalQuantity,
      subtotal: subtotal,
      subtotal0: subtotal0,
      subtotalIVA: subtotalIVA,
      discount: discount,
      subtotalWithDiscount: subtotalWithDiscount,
      totaTax: totaTax,
      deliveryCost: deliveryCost,
      total: total,
    );
  }
}

class Frequency {
  final String name;
  final int value;
  final bool isDefault;

  Frequency({this.name = '', this.value = 2, this.isDefault = false});

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value, 'is_default': isDefault};
  }

  factory Frequency.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final value = int.tryParse(json['value']?.toString() ?? '2') ?? 2;
    final isDefault = json['is_default'];

    return Frequency(name: name, value: value, isDefault: isDefault);
  }
}

class OfferRecurrence {
  final String? initialDiscount;
  final String? initialDiscountValue;
  final String? initialDiscountType;
  final String? initialSubtotal;
  final String? discount;
  final String? discountValue;
  final String? discountType;
  final String? subtotal;

  OfferRecurrence({
    this.initialDiscount = '',
    this.initialDiscountValue = '',
    this.initialDiscountType = '',
    this.initialSubtotal = '',
    this.discount = '',
    this.discountValue = '',
    this.discountType = '',
    this.subtotal = '',
  });

  factory OfferRecurrence.fromJson(Map<String, dynamic> json) {
    final initialDiscount = json['initial_discount']?.toString() ?? '';
    final initialDiscountValue =
        json['initial_discount_value']?.toString() ?? '';
    final initialDiscountType = json['initial_discount_type']?.toString() ?? '';
    final initialSubtotal = json['initial_subtotal']?.toString() ?? '';
    final discount = json['discount']?.toString() ?? '';
    final discountValue = json['discount_value']?.toString() ?? '';
    final discountType = json['discount_type']?.toString() ?? '';
    final subtotal = json['subtotal']?.toString() ?? '';

    return OfferRecurrence(
      initialDiscount: initialDiscount,
      initialDiscountValue: initialDiscountValue,
      initialDiscountType: initialDiscountType,
      initialSubtotal: initialSubtotal,
      discount: discount,
      discountValue: discountValue,
      discountType: discountType,
      subtotal: subtotal,
    );
  }
}

class RecurringOrder {
  final int id;
  String frequency;
  List<CartItem> lineItems;
  final String nextChargeDate;
  final String nextDeliveryDate;
  final int unpaidOrderId;
  final bool hasUnpaidOrder;
  final String notes;
  final CardDetail? card;
  final Address? shippingAddress;
  final String? startDate;
  final String status;
  final String userId;
  final DocumentSnapshot? snapshot;
  

  RecurringOrder({
    required this.id,
    required this.frequency,
    required this.lineItems,
    required this.nextChargeDate,
    this.nextDeliveryDate = '',
    this.unpaidOrderId = 0,
    this.hasUnpaidOrder = false,
    required this.notes,
    this.card,
    this.shippingAddress,
    this.startDate,
    this.status = '',
    this.userId = '',
    this.snapshot,

  });

  factory RecurringOrder.fromJson(Map<String, dynamic> json) {
    final hasUnpaidRaw = json['has_unpaid_order'];
    final hasUnpaidOrder =
        hasUnpaidRaw == true ||
        hasUnpaidRaw == 1 ||
        hasUnpaidRaw?.toString().toLowerCase() == 'true';

    return RecurringOrder(
      id: json['id'],
      frequency: json['frequency'].toString(),
      nextChargeDate: json['next_charge_date']?.toString() ?? '',
      nextDeliveryDate: json['next_delivery_date']?.toString() ?? '',
      unpaidOrderId:
          int.tryParse(json['unpaid_order_id']?.toString() ?? '') ?? 0,
      hasUnpaidOrder: hasUnpaidOrder,
      notes: json['notes'].toString(),
      card: CardDetail.fromJson(json['card']),
      startDate: json['start_date'],
      status: json['status'].toString(),
      userId: json['userId'].toString(),

      shippingAddress:
          json['shipping_address'] != null
              ? Address.fromJson(json['shipping_address'])
              : null,
      lineItems:
          (json['line_items'] as List<dynamic>)
              .map((item) => CartItem.fromJson(item))
              .toList(),
    );
  }
}

class Order {
  final String? id;
  final String? source;
  final String? shopifyOrderId;
  final ShopifyOrder? order;
  final String? notes;
  final String? createAt;
  final String? userId;
  final CardDetail? card;
  final Fulfillment? fulfillment;
  final String? extra;

  Order({
    this.id,
    this.source,
    required this.shopifyOrderId,
    required this.order,
    this.notes,
    this.createAt,
    this.userId,
    this.card,
    this.fulfillment,
    this.extra,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final extraMap = json['extra'];
    final extraMsg = extraMap is Map<String, dynamic>
        ? extraMap['message']?.toString()
        : null;
    final extra = (extraMsg != null && extraMsg != 'null') ? extraMsg : null;

    final orderPayload = json['order'];
    final Map<String, dynamic> orderMap;
    if (orderPayload is String) {
      orderMap = jsonDecode(orderPayload) as Map<String, dynamic>;
    } else if (orderPayload is Map<String, dynamic>) {
      orderMap = orderPayload;
    } else {
      throw FormatException('Order.fromJson: order must be String or Map');
    }

    final userIdVal = json['user_id'] ?? json['userId'];

    return Order(
      id: json['id']?.toString(),
      source: json['source']?.toString(),
      shopifyOrderId: json['shopify_order_id']?.toString(),
      notes: json['notes']?.toString(),
      createAt: json['created_at'] as String?,
      userId: userIdVal?.toString(),
      order: ShopifyOrder.fromJson(orderMap),
      card: json['card'] == null ? null : CardDetail.fromJson(json['card']),
      fulfillment:
          json['fulfillment'] == null
              ? null
              : Fulfillment.fromJson(
                  json['fulfillment'] as Map<String, dynamic>,
                ),
      extra: extra,
    );
  }
}

List<TrackingInfo>? _trackingInfoFromJson(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value
        .map((x) => TrackingInfo.fromJson(x as Map<String, dynamic>))
        .toList();
  }
  return null;
}

class Fulfillment {
  final int? id;
  final String? trackingNumber;
  final String? trackingUrl;
  final List<TrackingInfo>? trackingInfo;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final String? status;
  final String? statusTranslated;
  final List<Event>? events;
  final int? progress;
  final List<StepProgress>? steps;
  final int? actualStep;
  final LogisticProvider? logisticProvider;

  Fulfillment({
    required this.id,
    required this.trackingNumber,
    required this.trackingUrl,
    this.trackingInfo,
    this.dispatchedAt,
    this.deliveredAt,
    this.status,
    this.statusTranslated,
    this.events,
    this.progress,
    this.steps,
    this.actualStep,
    this.logisticProvider,
  });

  factory Fulfillment.fromJson(Map<String, dynamic> json) {
    return Fulfillment(
      id: json["id"],
      trackingNumber: json["tracking_number"] ?? '',
      trackingUrl: json["tracking_url"] ?? '',
      trackingInfo: _trackingInfoFromJson(json["tracking_info"]),
      dispatchedAt:
          json["dispatched_at"] != null
              ? DateTime.parse(json["dispatched_at"])
              : null,
      deliveredAt:
          json["delivered_at"] != null
              ? DateTime.parse(json["delivered_at"])
              : null,
      status: json["status"],
      statusTranslated: json["status_translated"],
      events:
          json["events"] == null
              ? null
              : (json["events"] as List? ?? [])
                  .map((e) => Event.fromJson(e))
                  .toList(),
      progress: json["progress"],
      steps:
          json["steps"] == null
              ? null
              : (json["steps"] as List? ?? [])
                  .map((s) => StepProgress.fromJson(s))
                  .toList(),
      actualStep: json["actual_step"],
      logisticProvider:
          json["logistic_provider"] != null
              ? LogisticProvider.fromJson(json["logistic_provider"])
              : null,
    );
  }

  String? getStatusStep() {
    if (steps != null && actualStep != null) {
      if (steps!.isNotEmpty) {
        for (var step in steps!) {
          if (step.position == actualStep!) {
            return step.step;
          }
        }
      }
      return null;
    } else {
      return null;
    }
    // return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  List<StepData> getStepsAvailable() {
    if (steps != null && actualStep != null) {
      if (steps!.isNotEmpty) {
        var newSteps = <StepData>[];
        for (var step in steps!) {
          if (step.position <= actualStep!) {
            newSteps.add(
              StepData(
                date: '',
                isCompleted: true,
                subtitle: step.position,
                title: step.step,
              ),
            );
          }
        }
        newSteps.sort((a, b) => b.subtitle.compareTo(a.subtitle));
        return newSteps;
      }
    }
    return [];
  }

  // Map<String, dynamic> toJson() => {
  //   "id": id,
  //   "tracking_number": trackingNumber,
  //   "tracking_url": trackingUrl,
  //   "tracking_info": trackingInfo.map((x) => x.toJson()).toList(),
  //   "dispatched_at": dispatchedAt?.toIso8601String(),
  //   "delivered_at": deliveredAt?.toIso8601String(),
  //   "status": status,
  //   "status_translated": statusTranslated,
  //   "events": events.map((e) => e.toJson()).toList(),
  //   "progress": progress,
  //   "steps": steps.map((s) => s.toJson()).toList(),
  //   "actual_step": actualStep,
  //   "logistic_provider": logisticProvider?.toJson(),
  // };
}

class TrackingInfo {
  final String nombre;
  final DateTime fecha;

  TrackingInfo({required this.nombre, required this.fecha});

  factory TrackingInfo.fromJson(Map<String, dynamic> json) => TrackingInfo(
    nombre: json["nombre"] ?? '',
    fecha: DateTime.parse(json["fecha"]),
  );

  // Map<String, dynamic> toJson() => {
  //   "nombre": nombre,
  //   "fecha": fecha.toIso8601String(),
  // };
}

class Event {
  final int? codigoTipoNovedad;
  final String? nombreTipoNovedad;
  final int? codigoDetalleNovedad;
  final String? nombreDetalleNovedad;
  final int? numeroMaximo;
  final String? observacion;
  final DateTime? fechaNovedad;

  Event({
    this.codigoTipoNovedad,
    this.nombreTipoNovedad,
    this.codigoDetalleNovedad,
    this.nombreDetalleNovedad,
    this.numeroMaximo,
    this.observacion,
    this.fechaNovedad,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    codigoTipoNovedad: json["codigoTipoNovedad"],
    nombreTipoNovedad: json["nombreTipoNovedad"],
    codigoDetalleNovedad: json["codigoDetalleNovedad"],
    nombreDetalleNovedad: json["nombreDetalleNovedad"],
    numeroMaximo: json["numeroMaximo"],
    observacion: json["observacion"],
    fechaNovedad:
        json["fechaNovedad"] != null
            ? DateTime.parse(json["fechaNovedad"])
            : null,
  );

  // Map<String, dynamic> toJson() => {
  //   "codigoTipoNovedad": codigoTipoNovedad,
  //   "nombreTipoNovedad": nombreTipoNovedad,
  //   "codigoDetalleNovedad": codigoDetalleNovedad,
  //   "nombreDetalleNovedad": nombreDetalleNovedad,
  //   "numeroMaximo": numeroMaximo,
  //   "observacion": observacion,
  //   "fechaNovedad": fechaNovedad?.toIso8601String(),
  // };
}

class StepProgress {
  final int position;
  final String step;

  StepProgress({required this.position, required this.step});

  factory StepProgress.fromJson(Map<String, dynamic> json) =>
      StepProgress(position: json["position"] ?? 0, step: json["step"] ?? '');

  Map<String, dynamic> toJson() => {"position": position, "step": step};
}

class LogisticProvider {
  final int id;
  final String name;
  final String? contactPhone;
  final String? contactEmail;

  LogisticProvider({
    required this.id,
    required this.name,
    this.contactPhone,
    this.contactEmail,
  });

  factory LogisticProvider.fromJson(Map<String, dynamic> json) =>
      LogisticProvider(
        id: json["id"],
        name: json["name"] ?? '',
        contactPhone: json["contact_phone"],
        contactEmail: json["contact_email"],
      );

  // Map<String, dynamic> toJson() => {
  //   "id": id,
  //   "name": name,
  //   "contact_phone": contactPhone,
  //   "contact_email": contactEmail,
  // };
}

class CustomerBilling {
  final int? id;
  final String? identification;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? type;
  final String? phone;
  bool isDefault;

  CustomerBilling({
    this.id,
    this.identification,
    this.firstName,
    this.lastName,
    this.email,
    this.type,
    this.phone,
    this.isDefault = false,
  });

  factory CustomerBilling.fromJson(Map<String, dynamic> json) {
    return CustomerBilling(
      id: json['id'] ?? 0,
      identification: json['identification'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'],
      email: json['email']?.toString(),
      type: json['type']?.toString(),
      phone: json['phone']?.toString(),
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJsonPagoPlux() {
    return {
      'documentNumber': identification,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'identification': identification,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'is_default': isDefault,
      'type': type,
    };
  }
}

class PaymentCardModel {
  final String? message;
  final DetailPaymentCardModel? details;
  final String? status;

  PaymentCardModel({this.message, this.details, this.status});

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    final detail = json['details'];
    return PaymentCardModel(
      message: json['message'].toString(),
      details:
          (detail != null && detail is Map<String, dynamic>)
              ? DetailPaymentCardModel.fromJson(detail)
              : null,
      status: json['status']?.toString(),
    );
  }
}

class DetailPaymentCardModel {
  final String? idTransaction;
  final String? url;

  DetailPaymentCardModel({this.idTransaction, this.url});

  factory DetailPaymentCardModel.fromJson(Map<String, dynamic> json) {
    return DetailPaymentCardModel(
      idTransaction: json['idTransaction']?.toString(),
      url: json['url_challenge']?.toString() ?? json['url']?.toString(),
    );
  }
}

class CardDetail {
  int id;
  String token;
  String amount;
  String cardInfo;
  String cardIssuer;
  String clientName;
  bool isExpired;
  String status;

  CardDetail({
    required this.id,
    required this.token,
    this.amount = '',
    this.cardInfo = '',
    this.cardIssuer = '',
    this.clientName = '',
    this.status = '',
    this.isExpired = true,
  });

  factory CardDetail.fromJson(Map<String, dynamic> json) {
    return CardDetail(
      id: json["id"],
      token: json["token"].toString(),
      amount: json["amount"].toString(),
      cardInfo: json["card_info"].toString(),
      cardIssuer: json["card_issuer"].toString(),
      status: json["status"].toString(),
      clientName: json["client_name"].toString(),
      isExpired: json["is_expired"],
    );
  }
}

class PaymentCardExpiration {
  String yearExpiracion;
  String monthExpiracion;

  PaymentCardExpiration({
    required this.yearExpiracion,
    required this.monthExpiracion,
  });

  factory PaymentCardExpiration.fromMap(Map<String, dynamic> json) {
    return PaymentCardExpiration(
      yearExpiracion: json["anioExpiracion"],
      monthExpiracion: json["mesExpiracion"],
    );
  }

  Map<String, dynamic> toJsonOrder() {
    return {"anioExpiracion": yearExpiracion, "mesExpiracion": monthExpiracion};
  }
}

class SubtotalModel {
  final double? subtotal;
  final double? minAmountFreeDelivery;
  final double? remainingAmount;
  final String? initialRecurrencePercentage;
  final String? recurrencePercentage;

  SubtotalModel({
    this.subtotal,
    this.minAmountFreeDelivery,
    this.remainingAmount,
    this.initialRecurrencePercentage,
    this.recurrencePercentage,
  });

  factory SubtotalModel.fromJson(Map<String, dynamic> json) {
    final subtotal = double.tryParse(json['subtotal'].toString()) ?? 0.0;
    final minAmountFreeDelivery =
        double.tryParse(json['minAmountFreeDelivery'].toString()) ?? 0.0;
    final remainingAmount =
        double.tryParse(json['remainingAmount'].toString()) ?? 0.0;
    final initial = json['discounts']['initial_recurrence'].toString();
    final recurrence = json['discounts']['recurrence'].toString();

    return SubtotalModel(
      subtotal: subtotal,
      minAmountFreeDelivery: minAmountFreeDelivery,
      remainingAmount: remainingAmount,
      initialRecurrencePercentage: initial,
      recurrencePercentage: recurrence,
    );
  }
}

class SettingsModel {
  final int id;
  final String? key;
  final String? value;
  final String? type;

  SettingsModel({required this.id, this.key, this.value, this.type});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'],
      key: json['key']?.toString(),
      value: json['value']?.toString(),
      type: json['type']?.toString(),
    );
  }

  bool get asBool {
    final normalized = value?.toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  double get asDouble {
    try {
      return double.parse(value ?? '0.0');
    } catch (_) {
      return 0.0;
    }
  }

  int get asInt {
    try {
      return int.parse(value ?? '0');
    } catch (_) {
      return 0;
    }
  }
}

class DynamicList<T> {
  List<T> _dynamicItems = [];

  void addItem(T item) {
    _dynamicItems.add(item);
  }

  void addItems(List<T> list) {
    _dynamicItems.addAll(list);
  }

  T getItem(int index) {
    return _dynamicItems[index];
  }

  int getSize() {
    return _dynamicItems.length;
  }
}

