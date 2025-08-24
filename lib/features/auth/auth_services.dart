// auth_services.dart (renamed from audio_services.dart for clarity, as it handles authentication UI)

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:needu/core/app_theme.dart';
import 'package:needu/core/data_state.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/core/size_config.dart';
import 'package:needu/features/auth/firebase_auth_services.dart';

enum AuthState { signIn, signUp, phoneAuth }

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

                case AuthState.phoneAuth:
                  return PhoneAuth(toggleState: toggleState);
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
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.check, color: Colors.black), // optional
            label: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(MaterialState.pressed)) {
                    return const Color(0xFF00CC66); // darker when pressed
                  }
                  return const Color(0xFF00FF88); // normal
                },
              ),
              overlayColor: MaterialStateProperty.all<Color>(
                Colors.black.withOpacity(0.1), // ripple overlay
              ),
              elevation: MaterialStateProperty.resolveWith<double>((states) {
                if (states.contains(MaterialState.pressed)) return 4; // lift up
                return 0;
              }),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: gImg
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.defaultIconSize,
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
                            ? const Icon(Icons.visibility,
                                color: AppColors.iconMuted)
                            : const Icon(Icons.visibility_off,
                                color: AppColors.iconMuted),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1),
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
            text: 'Sign In with Google',
            onPressed: AuthService.googleAuthenticating,
            isPrimary: false,
            gImg: true,
          ),

          SizedBox(height: SizeConfig.defaultHeight2),

          authButton(
            text: 'Continue as Guest',
            onPressed: () async {
              isGuest = true;
              await AuthService().signOut();
              context.go('/sosPage');
            },
            isPrimary: false,
          ),

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
            tFController: passwordController,
            obscureFunc: true,
            validator: (password) => password != null && password.length >= 6
                ? null
                : "Password must be at least 6 characters",
          ),

          SizedBox(height: SizeConfig.defaultHeight1),

          authButton(
            text: 'Sign Up',
            onPressed: () {
              if (_signUpFormKey.currentState!.validate()) {
                AuthService.signUpWithEmail(
                  emailController.text,
                  passwordController.text,
                );
              }
            },
          ),
          SizedBox(height: SizeConfig.defaultHeight1),
          authButton(
            text: 'Sign Up with Google',
            onPressed: AuthService.googleAuthenticating,
            isPrimary: false,
            gImg: true,
          ),
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
class PhoneAuth extends StatefulWidget {
  final VoidCallback toggleState;

  const PhoneAuth({super.key, required this.toggleState});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String? verificationId;
  bool otpSent = false;
  bool isLoading = false;

  // Send OTP using AuthService
  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid phone number")),
      );
      return;
    }

    setState(() => isLoading = true);

    await AuthService().verifyPhoneNumber(
      phone: phoneController.text.trim(),
      onCodeSent: (verId) {
        setState(() {
          verificationId = verId;
          otpSent = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent!")),
        );
      },
      onVerified: (user) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Auto-verified! Welcome ${user.phoneNumber}")),
        );
        // Navigate to home or SOS page
        context.go('/sosPage');
      },
      onError: (error) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      },
    );
  }

  // Verify OTP using AuthService
  Future<void> verifyOTP() async {
    if (verificationId == null) return;

    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter complete OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = await AuthService().verifyOTP(verificationId!, otp);

    setState(() => isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login successful: ${user.phoneNumber}")),
      );
      // Navigate to home or SOS page
      context.go('/sosPage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  // Resend OTP
  void resendCode() => sendOTP();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone Sign In',
            style: TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Text(
          otpSent
              ? 'Enter the 6-digit code sent to\n${phoneController.text}'
              : 'Enter your phone number to receive\na verification code',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 60),

        if (!otpSent)
          AuthTextField(
            label: 'Phone Number *',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            tFController: phoneController,
            validator: (phone) =>
                phone != null && phone.length >= 10 ? null : "Invalid phone",
          ),

        if (otpSent)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildOTPField(index)),
          ),

        const SizedBox(height: 40),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : authButton(
                text: otpSent ? 'Verify Code' : 'Send Code',
                onPressed: otpSent ? verifyOTP : sendOTP,
              ),
        const SizedBox(height: 24),

        if (otpSent)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive code? ",
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              GestureDetector(
                onTap: resendCode,
                child: const Text(
                  'Resend',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

        if (!otpSent)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Prefer email? ",
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              GestureDetector(
                onTap: () {
                  _authState = AuthState.signIn;
                  widget.toggleState();
                },
                child: const Text(
                  'Sign In with Email',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}