import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_template/config/config.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:http/http.dart' as http;

class ServicesAPI {
  static final ServicesAPI _instance = ServicesAPI._internal();
  factory ServicesAPI() => _instance;
  http.Client? _client;
  ServicesAPI._internal();

  Future<bool> isEmailRegistered(String email) async {
    final url = '${GeneralConfig.apiURL}api/users?email=$email';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['isRegistered'] == true;
      } else {
        print('Error en la solicitud: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<GenericResult<Customer>> verifyAndCreateCustomer(String? email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final idToken = await user.getIdToken();
      var url = '${GeneralConfig.apiURL}api/users';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      final json = jsonDecode(response.body);
      final result = GenericResult<Customer>.fromJson(
        json,
        (data) => Customer.fromJson(data),
      );

      if (response.statusCode == 200) {
        final customerId = result.data?.id;
        if (customerId != null) {
          return result;
        } else {
          throw Exception(result.getError());
        }
      } else {
        if (result.data?.canReactivate ?? false) {
          return GenericResult(
            success: false,
            data: result.data,
            errors: [
              GenericError(
                code: '',
                message:
                    result.getError() ??
                    'Ocurrio un error, por favor intentelo más tarde.',
              ),
            ],
          );
        }
        throw Exception(
          result.getError() ??
              'Ocurrio un error, por favor intentelo más tarde.',
        );
      }
    } catch (e) {
      print('Error: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<String?> assignCustomerIdFunction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final idToken = await user.getIdToken();
    const url = '${GeneralConfig.apiURL}api/users';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['id'];
      } else {
        print('Error en la solicitud: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<GenericResult<Collection>> getCollectionById(
    String? id,
    int? depth,
  ) async {
    var url = '${GeneralConfig.apiURL}api/collection?depth=${depth ?? 1}';
    if (id != null) {
      url = '$url&id=$id';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<Collection>.fromJson(
          json,
          (data) => Collection.fromJson(data),
        );
      } else {
        throw Exception('Hubo un error al obtener la informacion');
      }
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<Product>> getProductVariants(String id) async {
    var url = '${GeneralConfig.apiURL}api/products/variants/$id';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<Product>.fromJson(
          json,
          (data) => Product.fromJson(data),
        );
      } else {
        throw Exception('Hubo un error al obtener la informacion de productos');
      }
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Product>>> getProductsFromText(
    String text,
    String? after,
  ) async {
    var url = '${GeneralConfig.apiURL}api/products/search?textSearch=$text';
    if (after != null) {
      url = '$url&after=$after';
    }

    try {
      _client?.close();
      _client = http.Client();

      final response = await _client!.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // final data = json.data.products;
        return GenericResult<List<Product>>.fromJson(
          json,
          (product) => parseProductList(product),
        );
      } else {
        throw Exception('Hubo un error al obtener la informacion de productos');
      }
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<Address>> saveAddress(Address address) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      const url = '${GeneralConfig.apiURL}api/shopify/addresses';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(address.toJson()),
      );

      final json = jsonDecode(response.body);
      return GenericResult<Address>.fromJson(
        json,
        (data) => Address.fromJson(data),
      );
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<String>> updateAddress(Address address) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      const url = '${GeneralConfig.apiURL}api/shopify/addresses';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(address.toJson()),
      );

      final json = jsonDecode(response.body);

      return GenericResult<String>.fromJson(json, (data) => data.toString());
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Address>>> getCustomerAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      const url = '${GeneralConfig.apiURL}api/shopify/addresses';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);

      return GenericResult<List<Address>>.fromJson(
        json,
        (data) => parseAddressList(data),
      );
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<String>> deleteAddress(String addressId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      // final encodedAddressId = Uri.encodeComponent(addressId);

      final url = '${GeneralConfig.apiURL}api/shopify/addresses/$addressId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);

      return GenericResult<String>.fromJson(json, (data) => data.toString());
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CheckoutModel>> generateCheckout() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      const url = '${GeneralConfig.apiURL}api/checkout';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({"shippingCode": "STANDARD"}),
      );
      final json = jsonDecode(response.body);

      final result = GenericResult<CheckoutModel>.fromJson(
        json,
        (data) => CheckoutModel.fromJson(data),
      );
      if (response.statusCode == 200) {
        return result;
      } else {
        print('Error en la solicitud: ${response.body}');
        throw Exception(
          result.getError() ?? 'Hubo un error al generar el checkout',
        );
      }
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<ShopifyOrder>> createOrder(
    List<CartItem> products,
    Address address,
    CardDetail paymentCard,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      const url = '${GeneralConfig.apiURL}api/orders';
      final body = {
        "products": products.map((item) => item.toJson()).toList(),
        "address": address.toJsonOrder(),
        "user_card_id": paymentCard.id,
        "shipping_code": "STANDARD",
        "source": "App",
      };
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);
      final result = GenericResult<ShopifyOrder>.fromJson(
        json,
        (data) => ShopifyOrder.fromJson(data),
      );

      if (result.success) {
        return result;
      } else {
        throw Exception(
          result.getError() ?? 'Ocurrió un error al crear la orden.',
        );
      }
    } catch (e) {
      print('Exception en createOrder: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Product>>> getProductsByIds(
    List<String> productsIds,
  ) async {
    try {
      final query = productsIds.map((id) => 'ids[]=$id').join('&');

      final url = '${GeneralConfig.apiURL}api/products/multiple?$query';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<List<Product>>.fromJson(
          json,
          (data) => parseSimpleProductList(data),
        );
      } else {
        throw Exception('Hubo un error al obtener los productos');
      }
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<SubtotalModel>> generateSubtotals(
    List<CartItem> products,
  ) async {
    try {
      const url = '${GeneralConfig.apiURL}api/cart/subtotals';

      final user = FirebaseAuth.instance.currentUser;

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "products": products.map((item) => item.toJson()).toList(),
          "shippingCode": "STANDARD",
          "uid": user?.uid,
        }),
      );
      final json = jsonDecode(response.body);

      final result = GenericResult<SubtotalModel>.fromJson(
        json,
        (data) => SubtotalModel.fromJson(data),
      );
      if (response.statusCode == 200) {
        return result;
      } else {
        throw Exception(
          result.getError() ?? 'Hubo un error al obtener subtotales',
        );
      }
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<CartItem>>> getShopingCart() async {
    var url = '${GeneralConfig.apiURL}api/cart';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<List<CartItem>>.fromJson(
        json,
        (data) => parseCartList(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CartItem>> addProductToCart(
    Map<String, dynamic> product,
  ) async {
    var url = '${GeneralConfig.apiURL}api/cart';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(product),
      );

      final json = jsonDecode(response.body);
      return GenericResult<CartItem>.fromJson(
        json,
        (data) => CartItem.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CartItem>> updateProductCart(
    Map<String, dynamic> product,
  ) async {
    var url = '${GeneralConfig.apiURL}api/cart/${product['id']}';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(product),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<CartItem>.fromJson(
          json,
          (data) => CartItem.fromJson(data),
        );
      } else {
        throw Exception('Hubo un error al actualizar el producto.');
      }
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<GenericModel>> deleteProductCart(int productId) async {
    var url = '${GeneralConfig.apiURL}api/cart/$productId';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<GenericModel>.fromJson(
          json,
          (data) => GenericModel.fromJson(data),
        );
      } else {
        throw Exception(
          'Hubo un error al eliminar el producto del carrito de compras',
        );
      }
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<void> deleteCart() async {
    var url = '${GeneralConfig.apiURL}api/cart/items';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final _ = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      return;
    } catch (e) {
      print('error eliminando carrito: $e');
    }
  }

  Future<GenericResult<List<CustomerBilling>>>
  getBillingInformationList() async {
    var url = '${GeneralConfig.apiURL}api/billing-information';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<List<CustomerBilling>>.fromJson(
        json,
        (data) => parseCustomerBillingList(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CustomerBilling>> createBillingInformation(
    CustomerBilling data,
  ) async {
    var url = '${GeneralConfig.apiURL}api/billing-information';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      return GenericResult<CustomerBilling>.fromJson(
        json,
        (data) => CustomerBilling.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CustomerBilling>> updateCustomerBilling(
    CustomerBilling data,
  ) async {
    var url = '${GeneralConfig.apiURL}api/billing-information/${data.id}';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      return GenericResult<CustomerBilling>.fromJson(
        json,
        (data) => CustomerBilling.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<String>> removeCustomerBilling(
    CustomerBilling data,
  ) async {
    var url = '${GeneralConfig.apiURL}api/billing-information/${data.id}';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<String>.fromJson(json, (data) => data.toString());
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Order>>> getUserOrders(int page) async {
    var url = '${GeneralConfig.apiURL}api/orders?page=$page';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<List<Order>>.fromJson(
        json,
        (data) => parseOrderList(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<Order>> getOrderById(String orderId) async {
    var url = '${GeneralConfig.apiURL}api/orders/$orderId';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<Order>.fromJson(
          json,
          (data) => Order.fromJson(data),
        );
      } else {
        throw Exception('Error al obtener la orden');
      }
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<RecurringOrder>>> getUserRecurringOrder(
    int page,
  ) async {
    var url = '${GeneralConfig.apiURL}api/recurring-orders?page=$page';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<List<RecurringOrder>>.fromJson(
        json,
        (data) => parseRecurringOrderList(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Frequency>>?> obtainRecurrenceFrequency() async {
    var url = '${GeneralConfig.apiURL}api/recurrence-frequencies';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);
      final allDocs = GenericResult<List<Frequency>>.fromJson(
        json,
        (data) => parseFrecuencyList(data),
      );
      saveRecurrenceFrequencies(allDocs.data ?? []);
      return allDocs;
    } catch (e) {
      print(getFriendlyErrorMessage(e));
      return null;
    }
  }

  Future<GenericResult<OfferRecurrence>> getOfferRecurrence(
    String variantId,
    int quantity,
  ) async {
    final id = Uri.encodeComponent(variantId);
    var url =
        '${GeneralConfig.apiURL}api/products/recurrence-offer?id=$id&quantity=$quantity';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);
      return GenericResult<OfferRecurrence>.fromJson(
        json,
        (data) => OfferRecurrence.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<CardDetail>>> getCustomerCreditCards() async {
    var url = '${GeneralConfig.apiURL}api/cards/';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<List<CardDetail>>.fromJson(
        json,
        (data) => parseCardList(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CardDetail>> getUserCardById(int id) async {
    var url = '${GeneralConfig.apiURL}api/cards/?id=$id';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<CardDetail>.fromJson(
        json,
        (data) => CardDetail.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<CardDetail>> getCustomerCreditCardById(int id) async {
    var url = '${GeneralConfig.apiURL}api/cards/?id=$id';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<CardDetail>.fromJson(
        json,
        (data) => CardDetail.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<GenericModel>> deleteRecurrenceOrder(int id) async {
    var url = '${GeneralConfig.apiURL}api/recurring-orders/$id';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<GenericModel>.fromJson(
        json,
        (data) => GenericModel.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<RecurringOrder>> updateRecurrenceOrder(
    RecurringOrder order,
    Address? newAddress,
    int? newPayment,
  ) async {
    var url = '${GeneralConfig.apiURL}api/recurring-orders/${order.id}';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final idToken = await user.getIdToken();

      final updatedItemsLineJson =
          order.lineItems.map((item) => item.toJsonRecurrence()).toList();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'line_items': updatedItemsLineJson,
          'frequency': order.frequency,
          'shipping_address':
              newAddress != null
                  ? newAddress.toJsonOrder()
                  : order.shippingAddress?.toJsonOrder(),
          'payment_method_id': newPayment ?? order.card?.id,
        }),
      );

      final json = jsonDecode(response.body);
      return GenericResult<RecurringOrder>.fromJson(
        json,
        (data) => RecurringOrder.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<String>> retryPayment(String id) async {
    var url = '${GeneralConfig.apiURL}api/orders/$id/payments';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return GenericResult<String>.fromJson(json, (data) => data.toString());
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<void> loggError(Map<String, dynamic> data) async {
    var url = '${GeneralConfig.apiURL}api/activity-logs';

    try {
      final _ = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<GenericResult<String>> deleteUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final url = '${GeneralConfig.apiURL}api/users';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);

      return GenericResult<String>.fromJson(json, (data) => data.toString());
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<Customer>> recoverUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final url = '${GeneralConfig.apiURL}api/users/reactivate';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);

      return GenericResult<Customer>.fromJson(
        json,
        (data) => Customer.fromJson(data),
      );
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<int> getProductStock(String idProduct) async {
    try {
      final id = Uri.encodeComponent(idProduct);
      final url = '${GeneralConfig.apiURL}api/products/$id/inventory';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      final json = jsonDecode(response.body);
      return json['data']['total'] ?? 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<GenericResult<List<Product>>> getProductsCollection(
    String idCollection,
    String? after,
  ) async {
    var url = '${GeneralConfig.apiURL}api/collections/$idCollection/products';
    if (after != null) {
      url = '$url?after=$after';
    }
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);
      final products =
          json['data']?['collection']?['products'] ?? {'edges': []};
      return GenericResult<List<Product>>.fromJson({
        'data': products,
      }, (data) => parseProductList(data));
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<void> setToken(String token) async {
    var url = '${GeneralConfig.apiURL}api/users/devices';
    final deviceId = await GeneralConfig().getDeviceUuid();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuario no autenticado');
      return;
    }

    final idToken = await user.getIdToken();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'firebase_token': token, 'device_id': deviceId}),
      );

      final json = jsonDecode(response.body);
      print('token vinculado: ${json.toString()}');
    } catch (e) {
      print('error: ${e.toString()}');
    }
  }

  Future<GenericResult<List<Product>>> getProductsPreviouslyPurchased() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      final url = '${GeneralConfig.apiURL}api/reorder/suggestions';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<List<Product>>.fromJson(
          json,
          (data) => parseSimpleProductList(data),
        );
      } else {
        throw Exception(
          'Hubo un error al obtener los productos comprado previamente',
        );
      }
    } catch (e) {
      print(e);
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<Order>> updatePaymentOrder(
    Order order,
    int newPayment,
  ) async {
    var url = '${GeneralConfig.apiURL}api/orders/${order.id}';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final idToken = await user.getIdToken();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'user_card_id': newPayment}),
      );

      final json = jsonDecode(response.body);
      return GenericResult<Order>.fromJson(
        json,
        (data) => Order.fromJson(data),
      );
    } catch (e) {
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Species>>> getSpecies() async {
    try {
      final url = '${GeneralConfig.apiURL}api/catalogs/species';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Si la respuesta es directamente una lista, envolverla en un objeto
        final json =
            decoded is List
                ? {'data': decoded, 'success': true}
                : decoded as Map<String, dynamic>;
        return GenericResult<List<Species>>.fromJson(
          json,
          (data) => parseSpeciesList(data),
        );
      } else {
        print(
          'Error al obtener especies - Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Hubo un error al obtener las especies (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error al obtener especies: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Breed>>> getBreeds(String speciesKey) async {
    try {
      final encodedSpeciesKey = Uri.encodeComponent(speciesKey);
      final url =
          '${GeneralConfig.apiURL}api/catalogs/breeds/$encodedSpeciesKey';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Si la respuesta es directamente una lista, envolverla en un objeto
        final json =
            decoded is List
                ? {'data': decoded, 'success': true}
                : decoded as Map<String, dynamic>;
        return GenericResult<List<Breed>>.fromJson(
          json,
          (data) => parseBreedList(data),
        );
      } else {
        throw Exception('Hubo un error al obtener las razas');
      }
    } catch (e) {
      print('Error al obtener razas: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<Symptom>>> getSymptoms(String speciesKey) async {
    try {
      final encodedSpeciesKey = Uri.encodeComponent(speciesKey);
      final url =
          '${GeneralConfig.apiURL}api/catalogs/symptoms/$encodedSpeciesKey';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Si la respuesta es directamente una lista, envolverla en un objeto
        final json =
            decoded is List
                ? {'data': decoded, 'success': true}
                : decoded as Map<String, dynamic>;
        return GenericResult<List<Symptom>>.fromJson(
          json,
          (data) => parseSymptomList(data),
        );
      } else {
        throw Exception('Hubo un error al obtener los síntomas');
      }
    } catch (e) {
      print('Error al obtener síntomas: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<List<MedicalCondition>>> getMedicalConditions() async {
    try {
      final url = '${GeneralConfig.apiURL}api/catalogs/medical-conditions';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Si la respuesta es directamente una lista, envolverla en un objeto
        final json =
            decoded is List
                ? {'data': decoded, 'success': true}
                : decoded as Map<String, dynamic>;
        return GenericResult<List<MedicalCondition>>.fromJson(
          json,
          (data) => parseMedicalConditionList(data),
        );
      } else {
        throw Exception('Hubo un error al obtener las condiciones médicas');
      }
    } catch (e) {
      print('Error al obtener condiciones médicas: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult<HealthInsightResponse>> getHealthInsight(
    Map<String, dynamic> data,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final idToken = await user.getIdToken();

      final url = '${GeneralConfig.apiURL}api/quiz/health-insight';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
      );
      print(
        'Health insight response => status: ${response.statusCode}, '
        'headers: ${response.headers}, body: ${response.body}',
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenericResult<HealthInsightResponse>.fromJson(
          json,
          (data) =>
              HealthInsightResponse.fromJson(data as Map<String, dynamic>),
        );
      } else {
        throw Exception('Hubo un error al obtener el análisis de salud');
      }
    } catch (e) {
      print('Error al obtener análisis de salud: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }
}

