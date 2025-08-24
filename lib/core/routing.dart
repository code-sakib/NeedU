import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/features/audio/sos_page.dart';
import 'package:needu/features/auth/auth_services.dart';
import 'package:needu/profile_page.dart';
import 'package:needu/utilis/snackbar.dart';
import 'package:needu/wallet_page.dart';

GoRouter appRouting = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/sosPage',
      name: 'sosPage',
      builder: (context, state) => const SOSPage(),
    ),
    GoRoute(
      path: '/',
      name: 'auth',
      builder: (context, state) {
        return StreamBuilder(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            print('auth statechages');
            if (isGuest) {
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) => Utilis.showSnackBar('Logged in as guest.'),
              );
              return const SOSPage();
            } else {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (snapshot.hasData) {
                currentUser = auth.currentUser!;

                WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) => Utilis.showSnackBar('Login Successful.'),
                );

                return const SOSPage();
              } else if (!snapshot.hasData) {
                return AuthScreen();
              } else if (snapshot.hasError) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) => Utilis.showSnackBar(
                    snapshot.error.toString(),
                    isErr: false,
                  ),
                );
                return AuthScreen();
              } else {
                return AuthScreen();
              }
            }
          },
        );
      },
    ),
    GoRoute(
      path: '/profilePage',
      name: 'profilePage',
      builder: (context, state) => const ProfilePage(),
      routes: [
        GoRoute(
          path: '/wallet',
          name: 'wallet',
          builder: (context, state) => const WalletScreen(),
        ),
      ],
    ),
  ],
);
