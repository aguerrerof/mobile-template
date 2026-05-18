import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

enum PurchaseType { recurring, unique }

class ProductDetailViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String decription = '';
  List<String?> _flavors = [];
  List<ProductVariant?> _sizes = [];
  Product? _product;
  String? _selectedFlawor;
  ProductVariant? _selectedSize;
  PurchaseType? _purchaseType = PurchaseType.unique;
  int _count = 1;
  List<RecurringOrder> _recurringList = [];
  bool _showRecurringOptions = false;
  String? _itemSubtotalWithDiscountFirstTime;
  bool _loadingDiscount = false;
  int? _recurringIdSelected;
  String _percentageFirstTime = '0.0';
  String _percentageNormal = '0.0';
  List<int> _avaliableCount = [];

  bool get isLoading => _isLoading;
  List<String?> get flavors => _flavors;
  List<ProductVariant?> get sizes => _sizes;
  Product? get product => _product;
  String? get selectedFlawor => _selectedFlawor;
  ProductVariant? get selectedSize => _selectedSize;
  PurchaseType? get purchaseType => _purchaseType;
  int get count => _count;
  List<MediaItem> get images {
    if (_product == null) return [];

    // Obtener todas las URLs de imágenes de todas las variantes
    final variantImageUrls =
        _product!.variants
            .where(
              (variant) => variant.image != null && variant.image!.isNotEmpty,
            )
            .map((variant) => variant.image!)
            .toSet();

    // Filtrar las imágenes generales: excluir las que están en alguna variante
    final generalImages =
        _product!.media.where((mediaItem) {
          if (mediaItem.image?.url == null) return true;
          // Excluir si la URL coincide con alguna imagen de variante
          return !variantImageUrls.contains(mediaItem.image!.url);
        }).toList();

    // Obtener la variante seleccionada
    final selectedVariant = _product!.getSelectedVariant();

    // Si la variante seleccionada tiene imagen, agregarla al inicio
    if (selectedVariant != null &&
        selectedVariant.image != null &&
        selectedVariant.image!.isNotEmpty) {
      final variantMedia = MediaItem(
        mediaContentType: 'IMAGE',
        host: null,
        image: Imageshop(url: selectedVariant.image!),
      );
      return [variantMedia, ...generalImages];
    }

    // Si no hay imagen de variante, retornar solo las generales
    return generalImages;
  }

  bool get showRecurringOptions => _showRecurringOptions;
  List<RecurringOrder> get recurringList => _recurringList;
  int? get recurringIdSelected => _recurringIdSelected;
  String get percentageFirstTime => _percentageFirstTime;
  String get percentageNormal => _percentageNormal;
  String? get itemSubtotalWithDiscountFirstTime =>
      _itemSubtotalWithDiscountFirstTime;
  bool get loadingDiscount => _loadingDiscount;
  List<int> get avaliableCount => _avaliableCount;

  Future<void> getProduct(Product product) async {
    // _isLoading = true;
    // notifyListeners();
    updateProduct(product);
    updateCount();
    // final response = await ServicesAPI().getProductsByIds([product.id]);
    // updateProduct(response.data?.first ?? product);
    // updateCount();
  }

  Future<void> getFirstDiscount() async {
    final variantId = product?.getSelectedVariant()?.id ?? '';
    _loadingDiscount = true;
    notifyListeners();
    final response = await ServicesAPI().getOfferRecurrence(variantId, 1);

    if (response.success) {
      _itemSubtotalWithDiscountFirstTime = response.data?.initialSubtotal;
      _percentageFirstTime = response.data?.initialDiscountValue ?? '0.0';
      _percentageNormal = response.data?.discountValue ?? '0.0';
    }
    _loadingDiscount = false;
    notifyListeners();
  }

  void updateProduct(Product product) {
    _product = product;
    if (!product.isRecurring()) {
      _itemSubtotalWithDiscountFirstTime = null;
    }
    fetchProductDetail();
    notifyListeners();
  }

  void updateRecurringIdSelected(int? id) {
    _recurringIdSelected = id;
    notifyListeners();
  }

  void updateShowRecurring(bool status) {
    _showRecurringOptions = status;
    notifyListeners();
  }

  void updateCount() {
    final avaliable =
        product?.getSelectedVariant()?.inventoryQuantity ??
        product?.getSelectedVariant()?.inventoryItem?.totalStock ??
        0;
    _avaliableCount =
        avaliable > 0 ? List.generate(avaliable, (index) => index + 1) : [];
  }

  void setFlavor(String flavor) {
    _selectedFlawor = flavor;
    notifyListeners();
    updateSizes();
  }

  void setSize(ProductVariant size) {
    _selectedSize = size;
    _product!.setVariantSelected(_selectedSize!);
    if (product?.isRecurring() ?? false) {
      getFirstDiscount();
    } else {
      _itemSubtotalWithDiscountFirstTime = null;
    }
    updateCount();
    notifyListeners();
  }

  void setPurchaseType(PurchaseType type) {
    _purchaseType = type;
    notifyListeners();
  }

  void setCount(int count) {
    _count = count;
    notifyListeners();
  }

  Future<void> fetchProductDetail() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getProductVariants(_product?.id ?? '');

      if (result.success) {
        final newProduct = result.data;
        if (newProduct == null) {
          throw Exception('No se encontró la las variantes del producto');
        }

        _product!.setVariantList(newProduct.variants);
      }
      getFirstDiscount();

      _flavors = _product?.getFlawors() ?? [];

      _selectedFlawor = _flavors.isNotEmpty ? _flavors.first : null;
      updateSizes();
      notifyListeners();
    } catch (e) {
      print("Error fetchCollection: $e");
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSizes() {
    _sizes = _product?.getSizes(_selectedFlawor) ?? [];
    final nonNullSizes = _sizes.whereType<ProductVariant>().toList();
    if (nonNullSizes.isEmpty) return;
    final pick =
        nonNullSizes.firstWhereOrNull((v) => v.getStock() > 0) ??
        nonNullSizes.first;
    setSize(pick);
  }

  Future<void> addProduct(
    BuildContext context,
    LoadingViewModel loading,
  ) async {
    loading.show();
    try {
      final response = await ServicesAPI().getUserRecurringOrder(1);
      _recurringList = response.data ?? [];
      updateShowRecurring(true);
    } catch (e) {
      print('se genero un error: $e');
    } finally {
      loading.hide();
    }
  }

  void continueRecurring(BuildContext context) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      if (recurringIdSelected != null) {
        final data = _recurringList.firstWhere(
          (order) => order.id == recurringIdSelected,
        );

        final items = data.lineItems;

        final existingIndex = items.indexWhere(
          (item) => item.variantId == product!.getSelectedVariant()?.id,
        );
        if (existingIndex != -1) {
          items[existingIndex].quantity += 1;
          items[existingIndex].applyDiscount = true;
          items[existingIndex].applyTax =
              product!.getSelectedVariant()?.taxable ?? false;
        } else {
          items.add(
            CartItem(
              quantity: 1,
              price: double.parse(
                product!.getSelectedVariant()?.price ?? '0.0',
              ),
              title: product!.title,
              imageUrl:
                  (product!.getSelectedVariant()?.image != ''
                      ? product!.getSelectedVariant()?.image
                      : product!.getOnlyImages().first) ??
                  '',

              applyTax: product!.getSelectedVariant()?.taxable,
              variantId: product!.getSelectedVariant()?.id ?? '',
              deliveryDate: '',
              applyDiscount: true,
            ),
          );
        }

        data.lineItems = items;

        final response = await ServicesAPI().updateRecurrenceOrder(
          data,
          null,
          null,
        );
        if (context.mounted) {
          Navigator.pop(context);
          showCustomFlushbar(
            context,
            message:
                response.success
                    ? response.message ?? 'Sea agregó el producto a tu orden'
                    : response.getError() ??
                        'Existió un error al agregar tu producto a la orden.',
            backgroundColor:
                response.success
                    ? MyColors.successAlertColor
                    : MyColors.acentOne,
            textColor: MyColors.successAlerttextColor,
          );
        }
      } else {
        Navigator.pop(context);
        final loading = Provider.of<LoadingViewModel>(context, listen: false);
        addToCart(
          context: context,
          loading: loading,
          product: product!,
          count: count,
          goToConfirmCart: true,
          showBottomDetail: false,
          showPopup: false,
          isRecurrence: purchaseType == PurchaseType.recurring,
          applyDiscount: purchaseType == PurchaseType.recurring,
        );
      }
    } catch (e) {
      print({"error: $e"});
    } finally {
      loading.hide();
    }
  }
}

