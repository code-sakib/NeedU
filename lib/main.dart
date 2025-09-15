import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needu/app_provider.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/routing.dart';
import 'package:needu/utilis/size_config.dart';
import 'package:needu/firebase_options.dart';
import 'package:needu/utilis/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set status bar + navigation bar theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // make it blend
      statusBarIconBrightness: Brightness.light, // light = white icons
      // systemNavigationBarColor: Colors.black, // match bg
      // systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SharedPreferences.getInstance().then((value) {
    value.clear();
  });

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: ChangeNotifierProvider(
        create: (context) => AppProvider(),
        builder: (context, child) => MaterialApp.router(
          title: 'Flutter Demo',
          theme: AppTheme.theme,
          scaffoldMessengerKey: Utilis.messengerKey,
          routerConfig: appRouting,
        ),
      ),
    );
  }
}
