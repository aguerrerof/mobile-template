import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/models/response_models.dart';

enum OrderType { recurring, normal }

class OrderListViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<RecurringOrder> _recurringList = [];
  List<Order> _orderList = [];
  List<Order> _ordersInProgressList = [];
  bool _pageIsLoading = false;
  bool _canLoad = true;
  PageInfo? _page;

  bool get isLoading => _isLoading;
  List<RecurringOrder> get recurringList => _recurringList;
  List<Order> get orderList => _orderList;
  bool get pageIsLoading => _pageIsLoading;
  List<Order> get ordersInProgressList => _ordersInProgressList;

  void refreshOrders() {
    _canLoad = true;
    _orderList.clear();
    _ordersInProgressList.clear();
    _recurringList.clear();
    _page = null;
    notifyListeners();
  }

  Future<void> fetchOrdersRecurring(bool clear, bool onlyGetFirstPage) async {
    if (_recurringList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    } else {
      _pageIsLoading = true;
      notifyListeners();
    }

    try {
      int pageIndex = 1;
      if (!onlyGetFirstPage) {
        pageIndex = _page?.current ?? 1;
        if (_page != null && !_page!.hasNext()) {
          return;
        }
      }

      final response = await ServicesAPI().getUserRecurringOrder(pageIndex);
      if (response.success) {
        if (!onlyGetFirstPage) {
          _page = response.pageInfo;
        }
        final list = response.data ?? [];
        if (clear) {
          _recurringList = list;
        } else {
          _recurringList.addAll(list);
        }

        notifyListeners();
      }
    } catch (e) {
      print("Error fetch orders: $e");
    } finally {
      _isLoading = false;
      _pageIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders(bool clean) async {
    if (_orderList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    } else {
      _pageIsLoading = true;
      notifyListeners();
    }
    try {
      final pageIndex = _page?.current ?? 1;
      if (_page != null && !_page!.hasNext()) {
        return;
      }
      final response = await ServicesAPI().getUserOrders(pageIndex);
      if (response.success) {
        final pendingList =
            (response.data ?? []).where((order) {
              final status = order.fulfillment?.status ?? 'CANCELLED';
              return status != 'DELIVERED' && status != 'CANCELLED';
            }).toList();

        final doneList =
            (response.data ?? []).where((order) {
              final status = order.fulfillment?.status ?? 'CANCELLED';
              return status == 'DELIVERED' || status == 'CANCELLED';
            }).toList();

        _page = response.pageInfo;
        if (clean) {
          _ordersInProgressList = pendingList;
          _orderList = doneList;
        } else {
          _ordersInProgressList.addAll(pendingList);
          _orderList.addAll(doneList);
        }

        notifyListeners();
      }
    } catch (e) {
      print("Error fetchOrders: $e");
    } finally {
      _isLoading = false;
      _pageIsLoading = false;
      notifyListeners();
    }
  }
}

