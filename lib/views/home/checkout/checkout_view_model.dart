import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/Services/services_config.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/selection_modal_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:mobile_app_template/views/home/products/product_detail_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

enum PaymentType { creditDebit, paypal }

class CheckoutViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _addressLoading = false;
  bool _customerLoading = false;
  bool _cardsLoading = false;
  String _userName = '';
  CheckoutModel? _checkout;
  Address? _addressSelected;
  PaymentType _paymentType = PaymentType.creditDebit;
  GenericResult<ShopifyOrder>? _orderResult;
  List<CardDetail> _cardList = [];
  CustomerBilling? _customer;
  CardDetail? _cardSelected;
  List<Frequency> _frequencies = [];
  int? _currentTax;
  Frequency? _frequencySelected;
  Frequency? _defaultFrecuency;
  PurchaseType _purchaseType = PurchaseType.unique;
  List<CartItem> _recurrenceProducts = [];
  bool _showGeneralRecurrenceOptions = false;

  bool _doPop = false;
  String _message = '';

  bool get isLoading => _isLoading;
  bool get addressLoading => _addressLoading;
  bool get customerLoading => _customerLoading;
  bool get cardsLoading => _cardsLoading;
  CheckoutModel? get checkout => _checkout;
  String get userName => _userName;
  Address? get addressSelected => _addressSelected;
  PaymentType get paymentType => _paymentType;
  GenericResult<ShopifyOrder>? get orderResult => _orderResult;
  List<CardDetail> get cardList => _cardList;
  CustomerBilling? get customer => _customer;
  CardDetail? get cardSelected => _cardSelected;
  int? get currentTax => _currentTax;
  Frequency? get frequencySelected => _frequencySelected;
  List<Frequency> get frequencies => _frequencies;
  Frequency? get defaultFrecuency => _defaultFrecuency;
  PurchaseType get purchaseType => _purchaseType;
  List<CartItem> get recurrenceProducts => _recurrenceProducts;
  bool get showGeneralRecurrenceOptions => _showGeneralRecurrenceOptions;

  bool get doPop => _doPop;
  String get message => _message;

  void updateMessage(String value) {
    _message = value;
    notifyListeners();
  }

  void updateCardList(List<CardDetail> list) {
    _cardList = list;
    notifyListeners();
  }

  void updatePaymentType(PaymentType type) {
    _paymentType = type;
    notifyListeners();
  }

  void updateAddress(Address address) {
    _addressSelected = address;
    notifyListeners();
  }

  void updateCustomer(CustomerBilling customer) {
    _customer = customer;
    notifyListeners();
  }

  void updateCard(CardDetail? card) {
    _cardSelected = card;
    notifyListeners();
  }

  Future<void> fetchUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userName = currentUser.displayName ?? '';
        notifyListeners();
      }
    } catch (e) {
      print("Sin usuario: $e");
    }
  }

  Future<void> fetchTax() async {
    final tax = await ServicesConfig().getConfig<int>('iva');
    _currentTax = tax;
    notifyListeners();
  }

  Future<void> changeQuantity(
    CartItem item,
    int delta,
    BuildContext context,
  ) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    item.quantity = (item.quantity + delta).clamp(1, 99);
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await updateItemCart(item, delta);
      if (context.mounted) {
        await getCheckout();
      }
    } catch (e) {
      print('Error al cambiar cantidad productos del carrito: $e');
    } finally {
      loading.hide();
    }
  }

  Future<void> remove(BuildContext context, CartItem item) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await removeItem(item);
      if (context.mounted) {
        await getCheckout();
      }
    } catch (e) {
      print('Error al eliminar el producto del carrito: $e');
    } finally {
      loading.hide();
    }
  }

  Future<void> getCheckout() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ServicesAPI().generateCheckout();
      if (response.success) {
        _checkout = response.data;
        if (_checkout?.subtotal == 0.0) {
          _doPop = true;
          notifyListeners();
          return;
        }
        verifyProductsWithAvailableRecuring();
        fetchFrequencies();
        getRecurrenceProducts();
        notifyListeners();
      } else {
        updateMessage(response.getError() ?? "Error al generar el checkout");
      }
    } catch (e) {
      print('Error al obtener productos del carrito: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void fetchAddresses() async {
    _addressLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getCustomerAddresses();

      if (result.success) {
        print('result list address: ${result.data}');
        final list = result.data ?? [];
        if (list.isNotEmpty) {
          final defaultAddress = list.firstWhere(
            (address) => address.isDefault,
            orElse: () => list.first,
          );
          updateAddress(defaultAddress);
        }
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al guardar la dirección',
        );
      }
    } catch (e) {
      print(e);
    } finally {
      _addressLoading = false;
      notifyListeners();
    }
  }

  void fetchCustomersBilling() async {
    _customerLoading = true;
    notifyListeners();

    try {
      final response = await ServicesAPI().getBillingInformationList();
      if (!response.success) {
        throw Exception(response.getError());
      }

      final result = response.data ?? [];

      if (result.isNotEmpty) {
        final defaultCustomer = result.firstWhere(
          (customer) => customer.isDefault,
          orElse: () => result.first,
        );
        updateCustomer(defaultCustomer);
      }
    } catch (e) {
      print(e);
    } finally {
      _customerLoading = false;
      notifyListeners();
    }
  }

  void fetchCustomerCards() async {
    _cardsLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getCustomerCreditCards();

      if (result.success) {
        print('result customers cards: $result');

        final defaultCard = result.data?.first;
        updateCard(defaultCard);
        updateCardList(result.data ?? []);
      }
    } catch (e) {
      print(e);
    } finally {
      _cardsLoading = false;
      notifyListeners();
    }
  }

  void validate(BuildContext context) {
    if (_cardSelected == null) {
      showCustomFlushbar(
        context,
        message: 'Selecciona la tarjeta para el pago.',
      );
      return;
    }
    if (_addressSelected == null) {
      showCustomFlushbar(
        context,
        message:
            'Selecciona una dirección de entrega para continuar con tu pedido.',
      );
      return;
    }

    if (_customer == null) {
      showCustomFlushbar(
        context,
        message: 'Selecciona tus datos de facturación',
      );
      return;
    }

    saveOrder(context);
  }

  Widget crearTop(BuildContext context) {
    return Container(height: 0);
  }

  Future<void> saveOrder(BuildContext context) async {
    if ((_checkout?.items ?? []).isEmpty) {
      return;
    }
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      final result = await ServicesAPI().createOrder(
        _checkout?.items ?? [],
        addressSelected!,
        _cardSelected!,
      );

      if (result.success && result.data != null) {
        clearCart();
        _orderResult = result;
        notifyListeners();
        Singular.event("Purchase event");
        AnalyticsService().trackEvent('Order created Successfully');
      } else {
        AnalyticsService().trackEvent('Error creating order');
        throw Exception(
          result.getError() ?? 'Ha ocurrido un error al crear la orden.',
        );
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        showCustomFlushbar(context, message: getFriendlyErrorMessage(e));
      }
    } finally {
      loading.hide();
    }
  }

  Future<void> fetchFrequencies() async {
    _frequencies = getRecurrenceFrequency();
    if (_frequencies.isEmpty) {
      final response = await ServicesAPI().obtainRecurrenceFrequency();
      if (response != null && response.success) {
        _frequencies = response.data ?? [];
      }
    }
    _frequencySelected = _frequencies.firstWhere((freq) {
      return freq.isDefault;
    });
    _defaultFrecuency = _frequencySelected ?? _frequencies.first;
    setFrecuency(_defaultFrecuency);
  }

  void setFrecuency(Frequency? frequency) {
    if (frequency != null) {
      _frequencySelected = frequency;

      checkout?.items.forEachIndexed((index, item) {
        checkout?.items[index].frequency = frequency.name;
        updateItemCart(checkout!.items[index], null);
      });
    }
  }

  void getRecurrenceProducts() {
    final recurrenceProducts =
        checkout?.items.where((item) {
          return (item.isRecurrence ?? false);
        }).toList() ??
        [];
    if (recurrenceProducts.isNotEmpty) {
      _recurrenceProducts = recurrenceProducts;
      _purchaseType = PurchaseType.recurring;
    } else {
      final avaliableRecurrenceProducts =
          checkout?.items.where((item) {
            return (item.availableRecurrence);
          }).toList() ??
          [];
      _recurrenceProducts = avaliableRecurrenceProducts;
      _purchaseType = PurchaseType.unique;
    }

    notifyListeners();
  }

  void verifyProductsWithAvailableRecuring() {
    final recurrenceProducts =
        checkout?.items.where((item) {
          return (item.availableRecurrence);
        }).toList() ??
        [];
    _showGeneralRecurrenceOptions = recurrenceProducts.isNotEmpty;
    notifyListeners();
  }

  Future<void> setPurchaseType(PurchaseType type) async {
    switch (type) {
      case PurchaseType.recurring:
        checkout?.items.forEachIndexed((index, item) {
          if (checkout?.items[index].availableRecurrence ?? false) {
            checkout?.items[index].isRecurrence = true;
            checkout?.items[index].applyDiscount = true;
          }
        });

      case PurchaseType.unique:
        checkout?.items.forEachIndexed((index, item) {
          checkout?.items[index].isRecurrence = false;
          checkout?.items[index].applyDiscount = false;
        });
    }
    _isLoading = true;
    notifyListeners();
    if (checkout?.items != null) {
      for (final item in checkout!.items) {
        await updateItemCart(item, null);
      }
    }
    _isLoading = false;
    notifyListeners();
    await getCheckout();

    // getRecurrenceProducts();
    // _purchaseType = type;
    // notifyListeners();
  }

  Future<void> setPurchaseTypeProduct(int index, PurchaseType type) async {
    checkout?.items[index].isRecurrence = type == PurchaseType.recurring;
    checkout?.items[index].applyDiscount = type == PurchaseType.recurring;
    _isLoading = true;
    notifyListeners();
    // getRecurrenceProducts();
    await updateItemCart(checkout!.items[index], null);
    _isLoading = false;
    notifyListeners();
    await getCheckout();
  }

  // Future<void> showFrecuencyModal(BuildContext context, CartItem item) async {
  //   final selectedFrequency = Frequency(name: item.frequency ?? '');
  //   final result = await showSelectionModal<Frequency>(
  //     context: context,
  //     items: _frequencies,
  //     selectedItem: selectedFrequency,
  //     itemLabel: (item) => item.name,
  //     compare: (item1, item2) => item1.name == item2.name,
  //     title: 'Frecuencias disponibles',
  //     subtitle: 'Elige la frecuencia de envío que mejor se adapte a tu mascota',
  //   );

  //   if (result != null) {
  //     item.frequency = result.name;
  //     await updateItemCart(item);
  //     if (context.mounted) {
  //       await getCheckout(context);
  //     }
  //     notifyListeners();
  //   }
  // }
}

