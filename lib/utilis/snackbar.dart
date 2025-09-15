import 'package:flutter/material.dart';
import 'package:needu/core/app_theme.dart';

class Utilis {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String msg, {bool isErr = false}) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: isErr ? Colors.redAccent : AppColors.secondary,
      duration: const Duration(seconds: 1, milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => messengerKey.currentState!
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBar),
    );
  }

  static showLoading(bool toShow) {
    toShow
        ? WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) => Utilis.showSnackBar('Loading...'),
          )
        : messengerKey.currentState!.removeCurrentSnackBar();
  }
}
