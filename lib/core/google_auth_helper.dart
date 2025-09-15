import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needu/core/auth_state_manager.dart';
import 'package:needu/core/feedback_system.dart';
import 'package:needu/core/globals.dart';
import 'package:needu/features/auth/auth_service.dart';

/// Helper class for Google Authentication with proper integration
/// to the existing auth system and state management
class GoogleAuthHelper {
  /// Google Sign-In implementation that matches your working code
  /// This integrates with AuthStateManager for proper navigation and state management
  static Future<void> googleAuthenticating(BuildContext context) async {
    try {
      // Show loading feedback
      FeedbackSystem.showLoading('Signing in with Google...');

      // Use your working implementation
      final GoogleSignInAccount gUser = await GoogleSignIn.instance.authenticate();
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential (using only idToken as in your implementation)
      final OAuthCredential credentials = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await auth.signInWithCredential(credentials);

      // Hide loading feedback
      FeedbackSystem.hideCurrentSnackBar();

      // The Firebase Auth state change will be detected by the StreamBuilder
      // in AuthStateRouter, which will automatically trigger AuthStateManager.handleAuthStateChange
      // This will handle user data loading and navigation automatically

      // Show success message
      FeedbackSystem.showSuccess('Successfully signed in with Google!');

      // Navigation will be handled automatically by AuthStateRouter based on AuthState
    } catch (e) {
      // Hide loading feedback
      FeedbackSystem.hideCurrentSnackBar();
      
      // Handle error with comprehensive feedback
      FeedbackSystem.handleException(
        e,
        context: context,
        onRetry: () => googleAuthenticating(context),
      );
    }
  }

  /// Alternative method using the existing AuthService (recommended for consistency)
  /// This uses the centralized AuthService for consistency
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Show loading feedback
      FeedbackSystem.showLoading('Signing in with Google...');

      // Use the existing AuthService method (which is already updated)
      final user = await AuthService.signInWithGoogle();

      // Hide loading feedback
      FeedbackSystem.hideCurrentSnackBar();

      // Initialize user session with AuthStateManager
      await AuthStateManager.initializeUser(user);

      // Show success message
      FeedbackSystem.showSuccess('Successfully signed in with Google!');

      // Navigation will be handled automatically by AuthStateRouter
    } catch (e) {
      // Hide loading feedback
      FeedbackSystem.hideCurrentSnackBar();
      
      // Handle error with comprehensive feedback
      FeedbackSystem.handleException(
        e,
        context: context,
        onRetry: () => signInWithGoogle(context),
      );
    }
  }

  /// Sign out from Google (used internally by AuthService)
  static Future<void> signOutFromGoogle() async {
    try {
      // Try to sign out from Google if possible
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Log error but don't throw - sign out should be graceful
      debugPrint('Error signing out from Google: $e');
    }
  }
}

/// Extension to add Google Sign-In functionality to existing widgets
extension GoogleAuthExtension on State {
  /// Quick method to trigger Google Sign-In from any widget
  Future<void> signInWithGoogle() async {
    await GoogleAuthHelper.googleAuthenticating(context);
  }
}

/// Widget for Google Sign-In button with proper loading states
class GoogleSignInButton extends StatefulWidget {
  final String text;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool showIcon;

  const GoogleSignInButton({
    super.key,
    this.text = 'Sign in with Google',
    this.onSuccess,
    this.onError,
    this.showIcon = true,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await GoogleAuthHelper.googleAuthenticating(context);
      widget.onSuccess?.call();
    } catch (e) {
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF3A3A3A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showIcon) ...[
                    Image.asset(
                      'assets/google_logo.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}