import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/size_config.dart';
import 'package:needu/globals.dart';
import 'package:needu/profile_page.dart';
import 'package:needu/sos_page.dart';

void main() {
  runApp(const MyApp());

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // background of notch/notification area
        statusBarIconBrightness: Brightness.dark, // icons → dark (for white bg)
        statusBarBrightness: Brightness.light, // for iOS
      ),
    );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: SosPage());
  }
}