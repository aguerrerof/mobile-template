import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/notFound/empty_list_widget.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/address/address_list_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class AddressListScreen extends StatefulWidget {
  final bool canEdit;

  const AddressListScreen({Key? key, required this.canEdit});

  @override
  AddressListScreenState createState() => AddressListScreenState();
}

class AddressListScreenState extends State<AddressListScreen> {
  late AddressListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AddressListViewModel();
    viewModel.fetchAddresses();
  }

  Future<void> _handleRefresh() async {
    viewModel.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<LoadingViewModel>(context);

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<AddressListViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
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
                      'Direcciones',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
                viewModel.isLoading
                    ? const Padding(
                      padding: EdgeInsetsGeometry.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                    : viewModel.addresses.isEmpty
                    ? emptyView(
                      context,
                      'No tienes direcciones guardadas',
                      'Agrega una dirección para recibir tus pedidos',
                      null,
                      "Nueva dirección",
                      () {
                        AnalyticsService().trackEvent('Add address - List');
                        Navigator.pushNamed(context, '/address').then((value) {
                          viewModel.fetchAddresses();
                        });
                      },
                      null,
                      null,
                    )
                    : Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: RefreshIndicator(
                              onRefresh: _handleRefresh,
                              backgroundColor: MyColors.backgroundColor,
                              color: MyColors.btnColor,
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 24),
                                  ),
                                  if (!widget.canEdit)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 20,
                                        ),
                                        child: Text(
                                          'Seleccione la dirección.',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final address =
                                          viewModel.addresses[index];

                                      return GestureDetector(
                                        onTap: () {
                                          if (!widget.canEdit) {
                                            Navigator.pop(context, address);
                                          }
                                        },
                                        child: Card(
                                          color: MyColors.backgroundColor,
                                          margin: EdgeInsets.only(
                                            top: 10,
                                            left: 20,
                                            right: 20,
                                            bottom: 5,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                    text:
                                                        address.firstName
                                                            ?.toUpperCase() ??
                                                        '',
                                                    style: TextStyle(
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            address.isDefault
                                                                ? ' - Principal'
                                                                : '',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 14,
                                                          color: getTextColor(
                                                            context,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(height: 8),
                                                Text(
                                                  address.address1 ?? '',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  address.city ?? '',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Teléfono: ${address.phone}',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                if (widget.canEdit)
                                                  Wrap(
                                                    spacing: 5,
                                                    runSpacing: 8,
                                                    children: [
                                                      Row(
                                                        spacing: 5,
                                                        children: [
                                                          CustomButton(
                                                            height: 30,
                                                            type:
                                                                CustomButtonType
                                                                    .outline,
                                                            onPressed: () {
                                                              Navigator.pushNamed(
                                                                context,
                                                                '/address',
                                                                arguments: {
                                                                  'address':
                                                                      address,
                                                                },
                                                              ).then((value) {
                                                                viewModel
                                                                    .fetchAddresses();
                                                              });
                                                            },
                                                            label: 'Editar',
                                                          ),
                                                          CustomButton(
                                                            height: 30,
                                                            type:
                                                                CustomButtonType
                                                                    .outline,
                                                            onPressed: () {
                                                              viewModel
                                                                  .deleteAddress(
                                                                    context,
                                                                    loading,
                                                                    address,
                                                                    index,
                                                                  );
                                                            },
                                                            label: 'Eliminar',
                                                          ),
                                                        ],
                                                      ),

                                                      if (!address.isDefault)
                                                        CustomButton(
                                                          height: 30,
                                                          type:
                                                              CustomButtonType
                                                                  .outline,
                                                          onPressed: () {
                                                            viewModel
                                                                .updateAddress(
                                                                  context,
                                                                  loading,
                                                                  address,
                                                                  true,
                                                                );
                                                          },
                                                          label:
                                                              'Definir como principal',
                                                        ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }, childCount: viewModel.addresses.length),
                                  ),
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 70),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: MyColors.backgroundColor,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 20,
                                  left: 20,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: CustomButton(
                                  onPressed: () {
                                    AnalyticsService().trackEvent(
                                      'Add address - List',
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      '/address',
                                    ).then((value) {
                                      viewModel.fetchAddresses();
                                    });
                                  },

                                  label: 'Nueva dirección',
                                ),
                              ),
                            ),
                          ),
                        ],
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

