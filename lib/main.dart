import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/routing.dart';
import 'package:needu/core/size_config.dart';
import 'package:needu/features/audio/sos_page.dart';
import 'package:needu/features/auth/auth_services.dart';
import 'package:needu/firebase_options.dart';
import 'package:needu/utilis/snackbar.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      scaffoldMessengerKey: Utilis.messengerKey,
      routerConfig: appRouting,
    );
  }
}
