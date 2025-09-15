/// Centralized error handling system for the application
/// 
/// This file contains the AppError class that represents different types of errors
/// that can occur throughout the application, with user-friendly messages and
/// proper categorization for debugging and user feedback.

enum ErrorType {
  authentication,
  network,
  validation,
  storage,
  database,
  unknown,
}

/// Represents an application error with detailed information for debugging
/// and user-friendly messages for display
class AppError implements Exception {
  final ErrorType type;
  final String code;
  final String message;
  final String userMessage;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError._({
    required this.type,
    required this.code,
    required this.message,
    required this.userMessage,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates an authentication error
  factory AppError.authentication(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError._(
      type: ErrorType.authentication,
      code: code ?? 'auth_error',
      message: message,
      userMessage: _getAuthenticationUserMessage(code ?? 'auth_error'),
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a network error
  factory AppError.network(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError._(
      type: ErrorType.network,
      code: code ?? 'network_error',
      message: message,
      userMessage: 'Please check your internet connection and try again.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a validation error
  factory AppError.validation(
    String field,
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError._(
      type: ErrorType.validation,
      code: code ?? 'validation_error',
      message: message,
      userMessage: _getValidationUserMessage(field, message),
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a storage error
  factory AppError.storage(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError._(
      type: ErrorType.storage,
      code: code ?? 'storage_error',
      message: message,
      userMessage: 'Failed to save or retrieve data. Please try again.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates a database error
  factory AppError.database(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError._(
      type: ErrorType.database,
      code: code ?? 'database_error',
      message: message,
      userMessage: 'Database operation failed. Please try again.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Creates an unknown error
  factory AppError.unknown(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError._(
      type: ErrorType.unknown,
      code: code ?? 'unknown_error',
      message: message,
      userMessage: 'An unexpected error occurred. Please try again.',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Maps authentication error codes to user-friendly messages
  static String _getAuthenticationUserMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new code.';
      case 'session-expired':
        return 'Your session has expired. Please sign in again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Maps validation errors to user-friendly messages
  static String _getValidationUserMessage(String field, String message) {
    switch (field.toLowerCase()) {
      case 'email':
        return 'Please enter a valid email address.';
      case 'password':
        return 'Password must be at least 6 characters long.';
      case 'name':
        return 'Please enter your full name.';
      case 'phone':
      case 'phonenumber':
        return 'Please enter a valid phone number.';
      case 'emergencycontacts':
        return 'Please add at least one emergency contact.';
      default:
        return 'Please check your input and try again.';
    }
  }

  /// Converts the error to a map for logging purposes
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'code': code,
      'message': message,
      'userMessage': userMessage,
      'timestamp': timestamp.toIso8601String(),
      'originalError': originalError?.toString(),
      'stackTrace': stackTrace?.toString(),
    };
  }

  @override
  String toString() {
    return 'AppError(type: $type, code: $code, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppError &&
        other.type == type &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode {
    return type.hashCode ^ code.hashCode ^ message.hashCode;
  }
}