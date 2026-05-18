import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/components/list_products_section.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/views/home/search/search_screen_view_model.dart';
import 'package:provider/provider.dart';

class SearchScreenFull extends StatefulWidget {
  const SearchScreenFull({super.key});

  @override
  State<SearchScreenFull> createState() => _SearchScreenFullState();
}

class _SearchScreenFullState extends State<SearchScreenFull> {
  final ScrollController _scrollController = ScrollController();
  FocusNode? _focusNode;
  late SearchViewModel viewModel;
  bool _isEnable = true;
  Timer? _debounce;

  bool get isEnable => _isEnable;

  @override
  void initState() {
    super.initState();
    viewModel = SearchViewModel();
    AnalyticsService().trackScreen('Search Screen');
    _focusNode = FocusNode();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode?.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose;
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (viewModel.pageInfo != null) {
        if (viewModel.pageInfo!.hasNextPage ?? false) {
          viewModel.updateafter(viewModel.pageInfo?.endCursor);
          viewModel.fetchProducts(false);
        }
      }
    }
  }

  Widget search() {
    return Stack(
      children: [
        CustomTextField(
          maxHeight: 40,
          placeholder: 'Que necesita tu mascota hoy?',
          placeholderStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey,
          ),
          prefix: Icon(Icons.search, color: Colors.grey),
          borderColor: Color(0xFFE7EEF7).withAlpha(54),
          borderRadius: 20,
          fillColor: Color(0xFFF6F8FC),
          onChanged: (value) {
            _debounce?.cancel();
            viewModel.updateTextSearch(value);
            _debounce = Timer(const Duration(milliseconds: 400), () {
              viewModel.fetchProducts(true);
            });
          },
          onSubmit: (value) {
            setState(() {
              _isEnable = false;
              _focusNode?.dispose();
              _focusNode = null;
            });
          },
          inputAction: TextInputAction.search,
          focusNode: _focusNode,
          isEnable: isEnable,
          onTap: () {
            _focusNode?.requestFocus();
          },
        ),
        if (!isEnable)
          SizedBox(
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEnable = true;
                  _focusNode = FocusNode();
                  _focusNode?.requestFocus();
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Center(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            child: Column(
              children: [
                NavBarHeader(
                  showShoppingCart: true,
                  showBackButton: true,
                  showImageApp: false,
                  searchBelow: false,
                  showSearch: true,
                  children: search(),
                ),
                if (viewModel.products.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(top: 20),
                      child: ListProductsSection(
                        controller: _scrollController,
                        products: viewModel.products,
                        handleOnTap:
                            (e) => viewModel.goToProductDetail(context, e),
                      ),
                    ),
                  ),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                      strokeWidth: 1.5,
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

