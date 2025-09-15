// auth_services.dart (renamed from audio_services.dart for clarity, as it handles authentication UI)

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/account_setup.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/utilis/phone_pkg.dart';
import 'package:needu/utilis/size_config.dart';
import 'package:needu/features/auth/firebase_auth_services.dart';
import 'package:needu/utilis/snackbar.dart';

enum AuthState { signIn, signUp }

bool _allowedSignUp = false;

AuthState _authState = AuthState.signIn;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void toggleState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenHPadding,
            vertical: SizeConfig.screenVPadding,
          ),
          child: Builder(
            builder: (context) {
              switch (_authState) {
                case AuthState.signIn:
                  return SignIn(toggleState: toggleState);

                case AuthState.signUp:
                  return SignUp(toggleState: toggleState);
              }
            },
          ),
        ),
      ),
    );
  }
}

// Shared Auth Button Widget (extracted to remove redundancy)
Widget authButton({
  required String text,
  required VoidCallback onPressed,
  bool isPrimary = true,
  bool gImg = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: isPrimary
        ? ElevatedButton(
            onPressed: onPressed,

            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: gImg
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig
                          .blockHeight, // 1% of screen height = icon size
                    ),
                    child: Image.asset('assets/google_logo.png'),
                  )
                : const SizedBox.shrink(),
            label: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF3A3A3A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
  );
}

// Shared Auth Text Field (improved validation and keyboard type)
class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureFunc;
  final TextEditingController? tFController;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureFunc = false,
    this.tFController,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label),
          SizedBox(height: SizeConfig.blockHeight),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: widget.tFController,
              obscureText: widget.obscureFunc ? _obscureText : false,
              keyboardType: widget.label.toLowerCase().contains('phone')
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
              onChanged: (_) => _formKey.currentState?.validate(),
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(widget.icon, color: AppColors.iconMuted),
                suffixIcon: widget.obscureFunc
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: _obscureText
                            ? const Icon(
                                Icons.visibility,
                                color: AppColors.iconMuted,
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: AppColors.iconMuted,
                              ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.all(SizeConfig.paddingSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sign In Screen (made controllers instance vars, added form validation)
class SignIn extends StatefulWidget {
  final VoidCallback toggleState;

  const SignIn({super.key, required this.toggleState});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _signInFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Back', style: Theme.of(context).textTheme.titleLarge),
          Text(
            'Sign in to access your emergency contacts\nand safety features',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: SizeConfig.defaultHeight2),

          AuthTextField(
            label: 'Email *',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            tFController: emailController,
            validator: (email) =>
                email != null && EmailValidator.validate(email)
                ? null
                : "Enter a valid email",
          ),

          AuthTextField(
            label: 'Password *',
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            obscureFunc: true,
            tFController: passwordController,
            validator: (password) => password != null && password.length >= 6
                ? null
                : "Password must be at least 6 characters",
          ),

          SizedBox(height: SizeConfig.defaultHeight1),

          authButton(
            text: 'Sign In',
            onPressed: () {
              if (_signInFormKey.currentState!.validate()) {
                AuthService.signInWithEmail(
                  emailController.text,
                  passwordController.text,
                );
              }
            },
            isPrimary: true,
          ),
          SizedBox(height: SizeConfig.defaultHeight2),

          authButton(
            text: 'Continue as Guest',
            isPrimary: false,
            onPressed: () async {
              isGuest = true;
              await auth.signOut();
              context.go('/sos_page');
            },
          ),

          SocialButtonsSec(),
          SizedBox(height: SizeConfig.defaultHeight2),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              GestureDetector(
                onTap: () {
                  _authState = AuthState.signUp;
                  widget.toggleState();
                },
                child: Text(
                  'Sign Up',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sign Up Screen (similar improvements as SignIn)
class SignUp extends StatefulWidget {
  final VoidCallback toggleState;

  const SignUp({super.key, required this.toggleState});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _signUpFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final pNController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Account', style: Theme.of(context).textTheme.titleLarge),
          Text(
            'Join us to access emergency contacts\nand safety features',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          AuthTextField(
            label: 'Email *',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            tFController: emailController,
            validator: (email) =>
                email != null && EmailValidator.validate(email)
                ? null
                : "Enter a valid email",
          ),

          AuthTextField(
            label: 'Password *',
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            tFController: passwordController,
            obscureFunc: true,
            validator: (password) => password != null && password.length >= 6
                ? null
                : "Password must be at least 6 characters",
          ),

          SizedBox(height: SizeConfig.defaultHeight2),

          authButton(
            text: 'Sign Up',
            onPressed: () async {
              if (_signUpFormKey.currentState!.validate()) {
                await AuthService.signUpWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                // context.go('/accountSetup');
              }
            },
          ),

          SizedBox(height: SizeConfig.defaultHeight2),

          authButton(
            text: 'Continue as Guest',
            isPrimary: false,
            onPressed: () {
              isGuest = true;
              auth.signOut();
              context.go('/sosPage');
            },
          ),

          SocialButtonsSec(isNewUser: true),

          SizedBox(height: SizeConfig.defaultHeight2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              GestureDetector(
                onTap: () {
                  _authState = AuthState.signIn;
                  widget.toggleState();
                },
                child: Text(
                  'Sign In',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Phone Auth Screen (consolidated PhoneSignIn, OTPVerificationScreen, and PhoneAuth logic)
// Handles both phone entry and OTP verification in one widget with state management

class SocialButtonsSec extends StatelessWidget {
  const SocialButtonsSec({this.isNewUser = false, super.key});

  final bool isNewUser;

  static Widget layButton(String img, VoidCallback onPressed) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Image.asset('assets/$img.png'),
        ),
      ),
    );
  }

  divider() {
    return SizedBox(
      width: SizeConfig.screenWidth / 6,
      child: Divider(thickness: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: SizeConfig.screenVPadding),
          child: Row(
            children: [
              SizedBox(width: SizeConfig.blockWidth * 10),
              divider(),
              Text('     or continue with    '),
              divider(),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            layButton('google_logo', () async {
              await AuthService.googleAuthenticating(context);
              isNewUser ? context.go('/accountSetup') : null;
            }),
            layButton('apple_logo', () {}),
          ],
        ),
      ],
    );
  }
}
