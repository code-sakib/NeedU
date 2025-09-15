import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  updateState() {
    notifyListeners();
  }
}
