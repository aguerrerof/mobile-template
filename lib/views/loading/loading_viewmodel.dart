import 'package:flutter/cupertino.dart';

enum LoginType { password, code, recover }

class LoadingViewModel extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  void show() {
    _loading = true;
    notifyListeners();
  }

  void hide() {
    _loading = false;
    notifyListeners();
  }
}
