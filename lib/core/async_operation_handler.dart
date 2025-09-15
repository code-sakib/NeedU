import 'package:flutter/material.dart';
import 'package:needu/core/app_error.dart';
import 'package:needu/core/feedback_system.dart';

/// A comprehensive handler for async operations that provides consistent
/// loading states, error handling, and user feedback throughout the app
class AsyncOperationHandler {
  /// Execute an async operation with comprehensive error handling and feedback
  static Future<T?> execute<T>({
    required Future<T> Function() operation,
    BuildContext? context,
    String? loadingMessage,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool showLoadingSnackBar = false,
    bool showErrorDialog = false,
    bool enableRetry = true,
  }) async {
    // Show loading feedback if requested
    if (showLoadingSnackBar && loadingMessage != null) {
      FeedbackSystem.showLoading(loadingMessage);
    }

    try {
      // Execute the operation
      final result = await operation();

      // Hide loading feedback
      if (showLoadingSnackBar) {
        FeedbackSystem.hideCurrentSnackBar();
      }

      // Show success feedback if provided
      if (successMessage != null) {
        FeedbackSystem.showSuccess(successMessage);
      }

      // Call success callback
      onSuccess?.call();

      return result;
    } catch (e) {
      // Hide loading feedback
      if (showLoadingSnackBar) {
        FeedbackSystem.hideCurrentSnackBar();
      }

      // Handle the error with appropriate feedback
      if (enableRetry) {
        FeedbackSystem.handleException(
          e,
          context: context,
          showDialog: showErrorDialog,
          onRetry: () => execute(
            operation: operation,
            context: context,
            loadingMessage: loadingMessage,
            successMessage: successMessage,
            onSuccess: onSuccess,
            onError: onError,
            showLoadingSnackBar: showLoadingSnackBar,
            showErrorDialog: showErrorDialog,
            enableRetry: enableRetry,
          ),
        );
      } else {
        FeedbackSystem.handleException(
          e,
          context: context,
          showDialog: showErrorDialog,
        );
      }

      // Call error callback
      onError?.call();

      return null;
    }
  }

  /// Execute an async operation with state management for widgets
  static Future<T?> executeWithState<T>({
    required Future<T> Function() operation,
    required void Function(bool) setLoading,
    required void Function(String?) setError,
    BuildContext? context,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool enableRetry = true,
  }) async {
    // Set loading state
    setLoading(true);
    setError(null);

    try {
      // Execute the operation
      final result = await operation();

      // Clear loading state
      setLoading(false);

      // Show success feedback if provided
      if (successMessage != null) {
        FeedbackSystem.showSuccess(successMessage);
      }

      // Call success callback
      onSuccess?.call();

      return result;
    } catch (e) {
      // Clear loading state and set error
      setLoading(false);
      
      final errorMessage = e is AppError 
          ? e.userMessage 
          : 'An unexpected error occurred';
      setError(errorMessage);

      // Handle the error with appropriate feedback
      if (enableRetry) {
        FeedbackSystem.handleException(
          e,
          context: context,
          onRetry: () => executeWithState(
            operation: operation,
            setLoading: setLoading,
            setError: setError,
            context: context,
            successMessage: successMessage,
            onSuccess: onSuccess,
            onError: onError,
            enableRetry: enableRetry,
          ),
        );
      } else {
        FeedbackSystem.handleException(e, context: context);
      }

      // Call error callback
      onError?.call();

      return null;
    }
  }

  /// Execute multiple async operations in sequence with progress tracking
  static Future<List<T?>> executeSequence<T>({
    required List<Future<T> Function()> operations,
    required List<String> operationNames,
    BuildContext? context,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool stopOnFirstError = true,
  }) async {
    final results = <T?>[];
    
    for (int i = 0; i < operations.length; i++) {
      final operation = operations[i];
      final operationName = i < operationNames.length 
          ? operationNames[i] 
          : 'Operation ${i + 1}';

      FeedbackSystem.showProgress(
        message: '$operationName (${i + 1}/${operations.length})',
      );

      try {
        final result = await operation();
        results.add(result);
      } catch (e) {
        results.add(null);
        
        FeedbackSystem.hideCurrentSnackBar();
        
        if (stopOnFirstError) {
          FeedbackSystem.handleException(
            e,
            context: context,
            onRetry: () => executeSequence(
              operations: operations.sublist(i),
              operationNames: operationNames.sublist(i),
              context: context,
              successMessage: successMessage,
              onSuccess: onSuccess,
              onError: onError,
              stopOnFirstError: stopOnFirstError,
            ),
          );
          onError?.call();
          return results;
        } else {
          // Continue with next operation but log the error
          FeedbackSystem.showWarning('$operationName failed, continuing...');
        }
      }
    }

    FeedbackSystem.hideCurrentSnackBar();

    // Show success message if all operations completed
    if (successMessage != null) {
      FeedbackSystem.showSuccess(successMessage);
    }

    onSuccess?.call();
    return results;
  }

  /// Execute an async operation with timeout
  static Future<T?> executeWithTimeout<T>({
    required Future<T> Function() operation,
    required Duration timeout,
    BuildContext? context,
    String? loadingMessage,
    String? successMessage,
    String? timeoutMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    VoidCallback? onTimeout,
    bool enableRetry = true,
  }) async {
    return execute<T>(
      operation: () => operation().timeout(
        timeout,
        onTimeout: () {
          final message = timeoutMessage ?? 'Operation timed out';
          onTimeout?.call();
          throw AppError.network(message, code: 'timeout');
        },
      ),
      context: context,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      onSuccess: onSuccess,
      onError: onError,
      showLoadingSnackBar: loadingMessage != null,
      enableRetry: enableRetry,
    );
  }

  /// Execute an async operation with retry logic
  static Future<T?> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    BuildContext? context,
    String? loadingMessage,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      attempts++;
      
      final currentLoadingMessage = attempts > 1 
          ? '${loadingMessage ?? 'Loading'} (Attempt $attempts/$maxRetries)'
          : loadingMessage;

      try {
        return await execute<T>(
          operation: operation,
          context: context,
          loadingMessage: currentLoadingMessage,
          successMessage: successMessage,
          onSuccess: onSuccess,
          onError: onError,
          showLoadingSnackBar: loadingMessage != null,
          enableRetry: false, // We handle retry logic here
        );
      } catch (e) {
        if (attempts >= maxRetries) {
          // Final attempt failed, show error with manual retry option
          FeedbackSystem.handleException(
            e,
            context: context,
            onRetry: () => executeWithRetry(
              operation: operation,
              maxRetries: maxRetries,
              retryDelay: retryDelay,
              context: context,
              loadingMessage: loadingMessage,
              successMessage: successMessage,
              onSuccess: onSuccess,
              onError: onError,
            ),
          );
          onError?.call();
          return null;
        } else {
          // Wait before retrying
          await Future.delayed(retryDelay);
        }
      }
    }
    
    return null;
  }

  /// Execute an async operation with progress callback
  static Future<T?> executeWithProgress<T>({
    required Future<T> Function(void Function(double) onProgress) operation,
    required void Function(double) onProgress,
    BuildContext? context,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool enableRetry = true,
  }) async {
    try {
      final result = await operation(onProgress);
      
      if (successMessage != null) {
        FeedbackSystem.showSuccess(successMessage);
      }
      
      onSuccess?.call();
      return result;
    } catch (e) {
      if (enableRetry) {
        FeedbackSystem.handleException(
          e,
          context: context,
          onRetry: () => executeWithProgress(
            operation: operation,
            onProgress: onProgress,
            context: context,
            successMessage: successMessage,
            onSuccess: onSuccess,
            onError: onError,
            enableRetry: enableRetry,
          ),
        );
      } else {
        FeedbackSystem.handleException(e, context: context);
      }
      
      onError?.call();
      return null;
    }
  }
}

/// Mixin for widgets that need async operation handling
mixin AsyncOperationMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  void clearError() {
    setError(null);
  }

  Future<R?> executeAsync<R>({
    required Future<R> Function() operation,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool enableRetry = true,
  }) {
    return AsyncOperationHandler.executeWithState<R>(
      operation: operation,
      setLoading: setLoading,
      setError: setError,
      context: context,
      successMessage: successMessage,
      onSuccess: onSuccess,
      onError: onError,
      enableRetry: enableRetry,
    );
  }
}