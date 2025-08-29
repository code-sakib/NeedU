import 'package:flutter/material.dart';
import 'package:needu/core/app_theme.dart';

class Utilis {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String errorMsg, {bool isErr = false}) {
    final snackBar = SnackBar(
      content: Text(errorMsg),
      backgroundColor: isErr ? const Color(0xFFEF9A9A) : AppColors.primary,
      duration: const Duration(seconds: 1, milliseconds: 300),
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
