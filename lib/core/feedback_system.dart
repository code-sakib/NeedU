import 'package:flutter/material.dart';
import 'package:needu/core/app_error.dart';
import 'package:needu/core/error_handler.dart';

/// Comprehensive feedback system for showing success messages, errors, and retry mechanisms
class FeedbackSystem {
  static final GlobalKey<ScaffoldMessengerState> _messengerKey = 
      GlobalKey<ScaffoldMessengerState>();

  /// Get the messenger key for the app
  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  /// Show a success message with optional action
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show an error message with optional retry action
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: retryLabel,
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  /// Show a warning message
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_outlined,
      duration: duration,
      action: action,
    );
  }

  /// Show an info message
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show a loading message
  static void showLoading(String message) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.grey.shade700,
      icon: null,
      duration: const Duration(days: 1), // Long duration for loading
      showProgress: true,
    );
  }

  /// Hide the current snackbar
  static void hideCurrentSnackBar() {
    _messengerKey.currentState?.hideCurrentSnackBar();
  }

  /// Clear all snackbars
  static void clearSnackBars() {
    _messengerKey.currentState?.clearSnackBars();
  }

  /// Show a snackbar with custom styling
  static void _showSnackBar({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showProgress = false,
  }) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;

    // Clear existing snackbars
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (showProgress)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else if (icon != null)
            Icon(icon, color: Colors.white, size: 20),
          if (icon != null || showProgress) const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      action: action,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    messenger.showSnackBar(snackBar);
  }

  /// Show a dialog with error details and retry option
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
    bool canDismiss = true,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: canDismiss,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            if (canDismiss)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Dismiss'),
              ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text(retryLabel),
              ),
          ],
        );
      },
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: isDestructive
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    )
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Show a bottom sheet with options
  static Future<T?> showOptionsBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<BottomSheetOption<T>> options,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              ...options.map((option) => ListTile(
                leading: option.icon != null ? Icon(option.icon) : null,
                title: Text(option.title),
                subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
                onTap: () => Navigator.of(context).pop(option.value),
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Handle an AppError with appropriate feedback
  static void handleAppError(
    AppError error, {
    BuildContext? context,
    VoidCallback? onRetry,
    bool showDialog = false,
  }) {
    if (showDialog && context != null) {
      showErrorDialog(
        context,
        title: 'Error',
        message: error.userMessage,
        onRetry: onRetry,
      );
    } else {
      showError(
        error.userMessage,
        onRetry: onRetry,
      );
    }

    // Also use the existing error handler for logging
    ErrorHandler.handleError(error, context: context, showSnackBar: false);
  }

  /// Handle a generic exception with appropriate feedback
  static void handleException(
    dynamic exception, {
    BuildContext? context,
    VoidCallback? onRetry,
    bool showDialog = false,
  }) {
    final AppError error;
    
    if (exception is AppError) {
      error = exception;
    } else {
      error = AppError.unknown(
        exception?.toString() ?? 'An unexpected error occurred',
        originalError: exception,
      );
    }

    handleAppError(error, context: context, onRetry: onRetry, showDialog: showDialog);
  }

  /// Show operation progress with cancellation support
  static void showProgress({
    required String message,
    VoidCallback? onCancel,
    String cancelLabel = 'Cancel',
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.grey.shade700,
      duration: const Duration(days: 1), // Long duration
      showProgress: true,
      action: onCancel != null
          ? SnackBarAction(
              label: cancelLabel,
              textColor: Colors.white,
              onPressed: onCancel,
            )
          : null,
    );
  }
}

/// Option for bottom sheet selection
class BottomSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;

  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
}

/// Widget for showing inline error messages with retry option
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onDismiss;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(retryLabel),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: Colors.red, size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget for showing inline success messages
class InlineSuccessWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const InlineSuccessWidget({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: Colors.green, size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}