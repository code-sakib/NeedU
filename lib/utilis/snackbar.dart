import 'package:flutter/material.dart';

class Utilis {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String msg, {bool isErr = false}) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: isErr ? Color(0xFFEF9A9A) : Color(0xFFADECAF),
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
