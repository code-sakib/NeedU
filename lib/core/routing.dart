import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/account_setup.dart';
import 'package:needu/cloud_db.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/core/model_class.dart';
import 'package:needu/features/audio/sos_page.dart';
import 'package:needu/features/auth/auth_services.dart';
import 'package:needu/profile_page.dart';
import 'package:needu/utilis/snackbar.dart';
import 'package:needu/wallet_page.dart';

GoRouter appRouting = GoRouter(
  redirect: (context, state) {
    final uri = Uri.parse(state.uri.toString());
    if (uri.path.contains("firebaseauth/link")) {
      return '/'; // Always send back to home/root
    }
    return null;
  },
  initialLocation: '/',
  routes: [
    GoRoute(path: '/sos_page', builder: (context, state) => const SOSPage()),
    GoRoute(
      path: '/',
      name: 'auth',
      builder: (context, state) {
        
        return StreamBuilder(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (isGuest) {
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) => Utilis.showSnackBar('Logged in as guest.'),
              );
              return const SOSPage();
            } else if (auth.currentUser != null && snapshot.hasData) {
              //tohandle the case when user is signed-in with google and not created in DB
              return FutureBuilder(
                future: CloudDB.isUserAlreadyCreated(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    if (snapshot.data == true) {
                      return const SOSPage();
                    } else if (snapshot.data == false) {
                      
                      return const PhoneAuth2();
                    }
                  }
                  return Container();
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              // //hasData will always return a user that's why removing null checks
              // //Initializing current user globally

              // thisUser = CurrentUser(auth.currentUser!);

              // // CloudDB.fetchEmergencyContacts();

              // WidgetsBinding.instance.addPostFrameCallback(
              //   (timeStamp) => Utilis.showSnackBar('Login Successful.'),
              // );

              // return FutureBuilder(
              //   future: CloudDB.isUserAlreadyCreated(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasData) {
              //       if (snapshot.data == true) {
              //         thisUser = CurrentUser(auth.currentUser!);
              //         return const SOSPage();
              //       } else {
              //         return const PhoneAuth2();
              //       }
              //     } else {
              //       return const AuthScreen();
              //     }
              //   },
              // );
              return Center(child: Text('data'));
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
          },
        );
      },
      routes: [
        GoRoute(
          path: '/accountSetup',
          builder: (context, state) {
            return PhoneAuth2();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/profilePage',
      name: 'profilePage',
      builder: (context, state) => const ProfilePage(),
      routes: [
        GoRoute(
          path: 'wallet',
          name: 'wallet',
          builder: (context, state) => const WalletScreen(),
        ),
        GoRoute(
          path: 'editProfile',
          name: 'editProfile',
          builder: (context, state) => const EditProfileWidget(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) {
    final path = state.fullPath ?? '';
    print(path);
    print(state.error?.message);
    if (state.error!.message.contains("firebaseauth")) {
      // Just show a loader instead of crashing
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.go('/accountSetup');
        Utilis.showLoading(true);
      });

      return Container();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.go('/');
        Utilis.showSnackBar('Something went wrong.', isErr: true);
      });

      return Container();
    }
  },
);
