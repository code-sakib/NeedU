import 'package:flutter/material.dart';

class AppSnackBar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(msg, {bool colorGreen = true}) {
    if (msg == null) return null;

    final int duration = colorGreen ? 1 : 3;
    final Color color =
        colorGreen ? const Color(0xFFADECAF) : const Color(0xFFEF9A9A);

    final snackBar = SnackBar(
      dismissDirection:
          colorGreen ? DismissDirection.horizontal : DismissDirection.down,
      duration: Duration(seconds: duration),
      content: Wrap(
        spacing: 8,
        children: [
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      backgroundColor: color,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
