import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/address/create_edit_address_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

class CreateOrEditAddressScreen extends StatefulWidget {
  final Address? address;

  const CreateOrEditAddressScreen({Key? key, this.address});

  @override
  CreateOrEditAddressScreenState createState() =>
      CreateOrEditAddressScreenState();
}

class CreateOrEditAddressScreenState extends State<CreateOrEditAddressScreen> {
  GoogleMapController? _mapController;
  late CreateOrEditAddressViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CreateOrEditAddressViewModel();
    _determinePosition();
    Singular.event(
      widget.address == null ? "Create address page" : "Update address page",
    );
    AnalyticsService().trackEvent(
      widget.address == null ? "Create address page" : "Update address page",
    );
  }

  void _onCameraMove(CameraPosition position) {
    viewModel.updatePosition(position.target);
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      if (viewModel.initialPosition == null) {
        throw ('sin direccion');
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(
        viewModel.initialPosition!.latitude,
        viewModel.initialPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        viewModel.updateSelectedAddress(
          '${place.street}, ${place.locality}, ${place.country}',
        );
      }
    } catch (e) {
      viewModel.updateSelectedAddress('No se puede obtener la ubicación');
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      viewModel.updateUserPosition(
        LatLng(position.latitude, position.longitude),
      );
      if (widget.address == null) {
        viewModel.updatePosition(LatLng(position.latitude, position.longitude));
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(viewModel.initialPosition!),
        );
      } else {
        viewModel.updateCurrentAddress(widget.address!, _mapController);
      }

      _getAddressFromLatLng();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final loading = Provider.of<LoadingViewModel>(context);
    const cityAutocompleteDirection = OptionsViewOpenDirection.up;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CreateOrEditAddressViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            useSafeArea: true,
            child: Column(
              children: [
                NavBarHeader(
                  searchBelow: false,
                  showImageApp: false,
                  showSearch: false,
                  showShoppingCart: false,
                  showBackButton: true,
                  children: Center(
                    child: Text(
                      widget.address != null ? "Actualizar" : "Crear",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GestureDetector(
                          onPanDown: (_) {},
                          onPanEnd: (_) {},
                          child: AbsorbPointer(
                            absorbing: false,
                            child: SizedBox(
                              height: height * 0.3,
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    onMapCreated:
                                        (controller) =>
                                            _mapController = controller,
                                    initialCameraPosition: CameraPosition(
                                      target: viewModel.initialPosition!,
                                      zoom: 16,
                                    ),
                                    myLocationEnabled: true,
                                    onCameraMove: _onCameraMove,
                                    onCameraIdle: _getAddressFromLatLng,
                                    gestureRecognizers: {
                                      Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                      ),
                                    },
                                  ),
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Center(
                                        child: Transform.translate(
                                          offset: Offset(0, -20),
                                          child: Icon(
                                            Icons.location_on,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            top: 24,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                "Dirección",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                viewModel.selectedAddress,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: MyColors.secondary,
                                ),
                              ),
                              SizedBox(height: 14),
                              CustomTextField(
                                title: 'Nombre completo',
                                placeholder: '',
                                keyboardType: TextInputType.streetAddress,
                                onChanged:
                                    (value) => viewModel.updateFullName(value),
                                initialValue: widget.address?.firstName ?? '',
                              ),

                              CustomTextField(
                                title: 'Ubicación',
                                placeholder: 'Dirección de domicilio',
                                keyboardType: TextInputType.streetAddress,
                                onChanged:
                                    (value) =>
                                        viewModel.updateDeliveryAddress(value),
                                initialValue:
                                    widget.address?.address1
                                        ?.split(',')
                                        .first ??
                                    '',
                              ),

                              CustomTextField(
                                title: 'Departamento / Oficina / # Casa',
                                placeholder: 'Oficina X / Casa mzX vX',
                                onChanged:
                                    (value) =>
                                        viewModel.updateHouseNumber(value),
                                initialValue:
                                    widget.address?.address1?.split(',').last ??
                                    '',
                              ),

                              Autocomplete<String>(
                                optionsViewOpenDirection:
                                    cityAutocompleteDirection,
                                optionsMaxHeight: 220,
                                optionsViewBuilder: (
                                  BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options,
                                ) {
                                  return Align(
                                    alignment:
                                        cityAutocompleteDirection ==
                                                OptionsViewOpenDirection.up
                                            ? Alignment.bottomLeft
                                            : Alignment.topLeft,
                                    child: Material(
                                      color: MyColors.backgroundColor,
                                      elevation: 4.0,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 220,
                                        ),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(8.0),
                                          itemCount: options.length,
                                          shrinkWrap: true,
                                          itemBuilder: (
                                            BuildContext context,
                                            int index,
                                          ) {
                                            final String option = options
                                                .elementAt(index);
                                            return ListTile(
                                              title: Text(
                                                option,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  color: getTextColor(context),
                                                ),
                                              ),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                optionsBuilder: (
                                  TextEditingValue textEditingValue,
                                ) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  viewModel.prepareCitySearch(
                                    textEditingValue.text,
                                  );
                                  return viewModel.searchCitiesDebounced(
                                    textEditingValue.text,
                                  );
                                },
                                onSelected: (String selection) {
                                  viewModel.updateCity(selection);
                                  FocusScope.of(context).unfocus();
                                },
                                fieldViewBuilder: (
                                  context,
                                  controller,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  controller.text = viewModel.city;
                                  return CustomTextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    placeholder: "Selecciona una ciudad",
                                    title: "Ciudad",
                                  );
                                },
                              ),

                              CustomTextField(
                                title: 'Número de teléfono',
                                placeholder: '',
                                keyboardType: TextInputType.phone,
                                onChanged:
                                    (value) => viewModel.updatePhone(value),
                                initialValue: widget.address?.phone ?? '',
                                inputAction: TextInputAction.done,
                              ),

                              SizedBox(height: 20),
                              CustomButton(
                                onPressed:
                                    () =>
                                        viewModel.saveAddress(context, loading),
                                label: 'Guardar dirección',
                              ),
                              SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

