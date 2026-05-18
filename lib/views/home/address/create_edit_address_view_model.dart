import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/Services/services_config.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateOrEditAddressViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _selectedAddress = 'Buscando dirección...';
  LatLng? _initialPosition = LatLng(40.748817, -73.985428);
  LatLng? _userPosition;
  Address? _currentAddress;

  String _fullName = '';
  String _deliveryAddress = '';
  String _houseNumber = '';
  String _city = '';
  String _phone = '';

  bool get isLoading => _isLoading;
  String get selectedAddress => _selectedAddress;
  LatLng? get initialPosition => _initialPosition;

  String get fullName => _fullName;
  String get deliveryAddress => _deliveryAddress;
  String get houseNumber => _houseNumber;
  String get city => _city;
  String get phone => _phone;

  void updateCurrentAddress(
    Address address,
    GoogleMapController? mapController,
  ) {
    _currentAddress = address;
    _fullName = address.firstName ?? '';
    _city = address.city ?? '';
    _deliveryAddress = address.address1?.split(',').first ?? '';
    _houseNumber = address.address1?.split(',').last ?? '';
    _phone = address.phone ?? '';

    final locations = address.address2?.split(',') ?? [];
    if (locations.isNotEmpty && locations.length == 2) {
      final lat = double.tryParse(locations.first);
      final ln = double.tryParse(locations.last);
      if (lat != null && ln != null) {
        _initialPosition = LatLng(lat, ln);
        mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
      }
    }

    notifyListeners();
  }

  void updateSelectedAddress(String newAdddress) {
    _selectedAddress = newAdddress;
    notifyListeners();
  }

  void updatePosition(LatLng newPosition) {
    _initialPosition = newPosition;
    notifyListeners();
  }

  void updateUserPosition(LatLng newPosition) {
    _userPosition = newPosition;
    notifyListeners();
  }

  void updateCity(String value) {
    _city = value;
    notifyListeners();
  }

  void updateDeliveryAddress(String value) {
    _deliveryAddress = value;
    notifyListeners();
  }

  void updateHouseNumber(String value) {
    _houseNumber = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void updateFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  String _latestCityQuery = '';
  static const _cityDebounceMs = 350;
  final Map<String, List<String>> _cityCache = {};

  void prepareCitySearch(String text) {
    _latestCityQuery = text;
  }

  Future<List<String>> searchCities(String text) async {
    final data = await ServicesConfig().getCitiesStream(text);
    return data;
  }

  /// Búsqueda con debounce y cache para mejorar respuesta
  Future<List<String>> searchCitiesDebounced(String text) async {
    if (text.trim().isEmpty) return [];
    _latestCityQuery = text.trim();
    await Future.delayed(const Duration(milliseconds: _cityDebounceMs));
    if (_latestCityQuery != text.trim()) return [];
    final cacheKey = text.trim().toLowerCase();
    if (_cityCache.containsKey(cacheKey)) return _cityCache[cacheKey]!;
    final data = await ServicesConfig().getCitiesStream(text.trim());
    _cityCache[cacheKey] = data;
    return data;
  }

  void saveAddress(BuildContext context, LoadingViewModel loading) async {
    FocusScope.of(context).unfocus();
    if (_fullName.isEmpty) {
      showCustomFlushbar(
        context,
        message: 'Ingrese el nombre de la persona que recibirá el pedido.',
      );
      return;
    }
    if (_city.isEmpty) {
      showCustomFlushbar(
        context,
        message: 'Ingrese la ciudad a la que se realizará el envío.',
      );
      return;
    }

    if (_deliveryAddress.isEmpty) {
      showCustomFlushbar(
        context,
        message: 'Ingrese la dirección a la que se realizará el envío',
      );
      return;
    }
    if (_phone.isEmpty) {
      showCustomFlushbar(
        context,
        message:
            'Ingrese el número de teléfono de la persona que recibirá el pedido.',
      );
      return;
    }
    loading.show();
    try {
      final gps =
          '${_initialPosition?.latitude},${_initialPosition?.longitude}';

      final addess = Address(
        id: _currentAddress?.id,
        address1: '$_deliveryAddress,$_houseNumber',
        address2: gps,
        firstName: _fullName,
        city: _city,
        phone: _phone,
      );

      if (_currentAddress?.id != null) {
        final result = await ServicesAPI().updateAddress(addess);
        if (result.success) {
          if (context.mounted) {
            Navigator.pop(context);
            showCustomFlushbar(
              context,
              message: 'Se actualizó la dirección',
              backgroundColor: MyColors.successAlertColor,
              textColor: MyColors.successAlerttextColor,
            );
          }
        } else {
          throw Exception(
            result.errors.isNotEmpty
                ? 'Error message: ${result.errors[0].message}'
                : 'Error al actualizar la dirección',
          );
        }
      } else {
        final result = await ServicesAPI().saveAddress(addess);
        if (result.success) {
          if (context.mounted) {
            Navigator.pop(context, 'refresh');
            showCustomFlushbar(
              context,
              message: 'Dirección guardada correctamente.',
              backgroundColor: MyColors.successAlertColor,
              textColor: MyColors.successAlerttextColor,
            );
          }
        } else {
          throw Exception(
            result.errors.isNotEmpty
                ? 'Error message: ${result.errors[0].message}'
                : 'Error al guardar la dirección',
          );
        }
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
}

