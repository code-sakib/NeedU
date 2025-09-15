import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import 'feedback_system.dart';

/// Centralized error handler for processing and displaying errors throughout the application
/// 
/// This class provides methods for handling different types of errors, logging them
/// for debugging purposes, and showing appropriate user feedback.
class ErrorHandler {
  static final List<AppError> _errorLog = [];
  static const int _maxLogSize = 100;

  /// Handles an AppError by logging it and showing user feedback
  static void handleError(
    AppError error, {
    BuildContext? context,
    bool showSnackBar = true,
    bool logError = true,
  }) {
    if (logError) {
      _logError(error);
    }

    if (showSnackBar && context != null) {
      _showUserMessage(context, error.userMessage, error.type);
    }

    _handleSpecificError(error);
  }

  /// Handles a generic exception by converting it to an AppError
  static void handleException(
    dynamic exception, {
    StackTrace? stackTrace,
    BuildContext? context,
    bool showSnackBar = true,
    bool logError = true,
  }) {
    final AppError error;

    if (exception is AppError) {
      error = exception;
    } else {
      error = _convertExceptionToAppError(exception, stackTrace);
    }

    handleError(
      error,
      context: context,
      showSnackBar: showSnackBar,
      logError: logError,
    );
  }

  /// Logs an error for debugging purposes
  static void _logError(AppError error) {
    // Add to internal log
    _errorLog.add(error);
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }

    // Log to console in debug mode
    if (kDebugMode) {
      developer.log(
        'AppError: ${error.message}',
        name: 'ErrorHandler',
        error: error.originalError,
        stackTrace: error.stackTrace,
        level: _getLogLevel(error.type),
      );
    }

    // In production, you might want to send errors to a crash reporting service
    // like Firebase Crashlytics or Sentry
    if (kReleaseMode) {
      _reportErrorToService(error);
    }
  }

  /// Shows a user-friendly message using the FeedbackSystem
  static void _showUserMessage(
    BuildContext context,
    String message,
    ErrorType errorType,
  ) {
    // Use the new FeedbackSystem for consistent error display
    switch (errorType) {
      case ErrorType.validation:
        FeedbackSystem.showWarning(message);
        break;
      case ErrorType.network:
        FeedbackSystem.showError(
          message,
          onRetry: () {
            // Network errors can be retried
            // The specific retry logic should be implemented by the caller
            FeedbackSystem.showInfo('Please try your action again');
          },
        );
        break;
      case ErrorType.authentication:
      case ErrorType.storage:
      case ErrorType.database:
      case ErrorType.unknown:
        FeedbackSystem.showError(message);
        break;
    }
  }

  /// Handles specific error types with custom logic
  static void _handleSpecificError(AppError error) {
    switch (error.type) {
      case ErrorType.authentication:
        _handleAuthenticationError(error);
        break;
      case ErrorType.network:
        _handleNetworkError(error);
        break;
      case ErrorType.validation:
        _handleValidationError(error);
        break;
      case ErrorType.storage:
        _handleStorageError(error);
        break;
      case ErrorType.database:
        _handleDatabaseError(error);
        break;
      case ErrorType.unknown:
        _handleUnknownError(error);
        break;
    }
  }

  /// Converts a generic exception to an AppError
  static AppError _convertExceptionToAppError(
    dynamic exception,
    StackTrace? stackTrace,
  ) {
    final String message = exception?.toString() ?? 'Unknown error occurred';

    // Try to identify the error type based on the exception
    if (message.contains('SocketException') ||
        message.contains('NetworkException') ||
        message.contains('TimeoutException')) {
      return AppError.network(
        message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    if (message.contains('FirebaseAuth') || message.contains('auth')) {
      return AppError.authentication(
        message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    if (message.contains('Firestore') || message.contains('database')) {
      return AppError.database(
        message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    if (message.contains('Storage') || message.contains('upload')) {
      return AppError.storage(
        message,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }

    return AppError.unknown(
      message,
      originalError: exception,
      stackTrace: stackTrace,
    );
  }

  /// Gets the appropriate log level for an error type
  static int _getLogLevel(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.validation:
        return 800; // INFO level
      case ErrorType.network:
        return 900; // WARNING level
      case ErrorType.authentication:
      case ErrorType.storage:
      case ErrorType.database:
      case ErrorType.unknown:
        return 1000; // SEVERE level
    }
  }

  /// Gets the appropriate SnackBar color for an error type
  static Color _getSnackBarColor(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.network:
        return Colors.blue;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.storage:
      case ErrorType.database:
        return Colors.deepOrange;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  /// Handles authentication-specific errors
  static void _handleAuthenticationError(AppError error) {
    // Could trigger navigation to login screen, clear user session, etc.
    if (kDebugMode) {
      developer.log('Authentication error handled: ${error.code}');
    }
  }

  /// Handles network-specific errors
  static void _handleNetworkError(AppError error) {
    // Could trigger retry mechanisms, offline mode, etc.
    if (kDebugMode) {
      developer.log('Network error handled: ${error.code}');
    }
  }

  /// Handles validation-specific errors
  static void _handleValidationError(AppError error) {
    // Could focus on specific form fields, highlight errors, etc.
    if (kDebugMode) {
      developer.log('Validation error handled: ${error.code}');
    }
  }

  /// Handles storage-specific errors
  static void _handleStorageError(AppError error) {
    // Could clear cache, retry uploads, etc.
    if (kDebugMode) {
      developer.log('Storage error handled: ${error.code}');
    }
  }

  /// Handles database-specific errors
  static void _handleDatabaseError(AppError error) {
    // Could trigger data sync, offline mode, etc.
    if (kDebugMode) {
      developer.log('Database error handled: ${error.code}');
    }
  }

  /// Handles unknown errors
  static void _handleUnknownError(AppError error) {
    // Could trigger error reporting, fallback mechanisms, etc.
    if (kDebugMode) {
      developer.log('Unknown error handled: ${error.code}');
    }
  }

  /// Reports error to external service (placeholder for production)
  static void _reportErrorToService(AppError error) {
    // In a real app, you would integrate with services like:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // etc.
    
    if (kDebugMode) {
      developer.log('Error would be reported to external service: ${error.code}');
    }
  }

  /// Gets the error log for debugging purposes
  static List<AppError> get errorLog => List.unmodifiable(_errorLog);

  /// Clears the error log
  static void clearErrorLog() {
    _errorLog.clear();
  }

  /// Gets error statistics for debugging
  static Map<ErrorType, int> getErrorStatistics() {
    final Map<ErrorType, int> stats = {};
    for (final error in _errorLog) {
      stats[error.type] = (stats[error.type] ?? 0) + 1;
    }
    return stats;
  }

  /// Creates a formatted error report for debugging
  static String generateErrorReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== Error Report ===');
    buffer.writeln('Total errors: ${_errorLog.length}');
    buffer.writeln('Generated at: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    final stats = getErrorStatistics();
    buffer.writeln('Error Statistics:');
    for (final entry in stats.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }
    buffer.writeln();

    buffer.writeln('Recent Errors:');
    final recentErrors = _errorLog.take(10).toList();
    for (int i = 0; i < recentErrors.length; i++) {
      final error = recentErrors[i];
      buffer.writeln('${i + 1}. [${error.type}] ${error.code}: ${error.message}');
      buffer.writeln('   Time: ${error.timestamp.toIso8601String()}');
      if (error.originalError != null) {
        buffer.writeln('   Original: ${error.originalError}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}