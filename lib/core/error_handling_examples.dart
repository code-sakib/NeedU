/// Example usage of the centralized error handling system
/// 
/// This file demonstrates how to use AppError and ErrorHandler
/// in different scenarios throughout the application.

import 'package:flutter/material.dart';
import 'app_error.dart';
import 'error_handler.dart';

/// Example service class showing how to use error handling in data operations
class ExampleService {
  /// Example method showing authentication error handling
  static Future<void> signInExample(String email, String password, BuildContext context) async {
    try {
      // Simulate authentication logic
      if (email.isEmpty) {
        throw AppError.validation('email', 'Email is required');
      }
      
      if (password.length < 6) {
        throw AppError.validation('password', 'Password too short');
      }
      
      // Simulate network call that might fail
      await Future.delayed(Duration(seconds: 1));
      
      // Simulate authentication failure
      if (email == 'wrong@example.com') {
        throw AppError.authentication(
          'Invalid credentials provided',
          code: 'wrong-password',
        );
      }
      
      // Success case
      print('Sign in successful');
      
    } catch (error) {
      // Handle any error that occurs
      ErrorHandler.handleException(
        error,
        context: context,
        showSnackBar: true,
        logError: true,
      );
      rethrow; // Re-throw if the calling code needs to handle it
    }
  }

  /// Example method showing database error handling
  static Future<Map<String, dynamic>?> fetchUserDataExample(String uid, BuildContext context) async {
    try {
      // Simulate network check
      if (!await _hasNetworkConnection()) {
        throw AppError.network('No internet connection available');
      }
      
      // Simulate database operation
      await Future.delayed(Duration(milliseconds: 500));
      
      // Simulate database error
      if (uid == 'invalid-uid') {
        throw AppError.database(
          'User document not found',
          code: 'document-not-found',
        );
      }
      
      // Success case
      return {
        'uid': uid,
        'name': 'John Doe',
        'email': 'john@example.com',
      };
      
    } catch (error) {
      ErrorHandler.handleException(
        error,
        context: context,
        showSnackBar: true,
        logError: true,
      );
      return null; // Return null on error
    }
  }

  /// Example method showing storage error handling
  static Future<String?> uploadFileExample(String filePath, BuildContext context) async {
    try {
      // Validate file
      if (filePath.isEmpty) {
        throw AppError.validation('file', 'File path is required');
      }
      
      // Simulate file size check
      if (filePath.contains('large')) {
        throw AppError.storage(
          'File size exceeds limit',
          code: 'file-too-large',
        );
      }
      
      // Simulate upload
      await Future.delayed(Duration(seconds: 2));
      
      // Simulate upload failure
      if (filePath.contains('corrupt')) {
        throw AppError.storage(
          'File upload failed due to corruption',
          code: 'upload-failed',
        );
      }
      
      // Success case
      return 'https://example.com/uploaded-file.jpg';
      
    } catch (error) {
      ErrorHandler.handleException(
        error,
        context: context,
        showSnackBar: true,
        logError: true,
      );
      return null;
    }
  }

  /// Example method showing how to handle multiple error types
  static Future<bool> complexOperationExample(BuildContext context) async {
    try {
      // Step 1: Validate input
      final input = await _getInputData();
      if (input == null) {
        throw AppError.validation('input', 'Required input data is missing');
      }
      
      // Step 2: Network operation
      final networkResult = await _performNetworkOperation(input);
      if (networkResult == null) {
        throw AppError.network('Failed to connect to server');
      }
      
      // Step 3: Database operation
      final dbResult = await _performDatabaseOperation(networkResult);
      if (dbResult == null) {
        throw AppError.database('Failed to save data to database');
      }
      
      // Step 4: Storage operation
      final storageResult = await _performStorageOperation(dbResult);
      if (storageResult == null) {
        throw AppError.storage('Failed to store file');
      }
      
      return true;
      
    } on AppError catch (appError) {
      // Handle known app errors
      ErrorHandler.handleError(
        appError,
        context: context,
        showSnackBar: true,
        logError: true,
      );
      return false;
      
    } catch (unknownError, stackTrace) {
      // Handle unknown errors
      ErrorHandler.handleException(
        unknownError,
        stackTrace: stackTrace,
        context: context,
        showSnackBar: true,
        logError: true,
      );
      return false;
    }
  }

  /// Example of how to create custom error types for specific business logic
  static AppError createCustomBusinessError(String operation, String details) {
    return AppError.validation(
      operation,
      'Business rule violation: $details',
      code: 'business-rule-violation',
    );
  }

  /// Example of how to handle errors without showing UI feedback
  static Future<void> backgroundOperationExample() async {
    try {
      // Some background operation
      await Future.delayed(Duration(seconds: 1));
      throw Exception('Background operation failed');
      
    } catch (error) {
      // Log error but don't show UI feedback
      ErrorHandler.handleException(
        error,
        showSnackBar: false, // Don't show snackbar for background operations
        logError: true,      // But still log for debugging
      );
    }
  }

  // Helper methods for examples
  static Future<bool> _hasNetworkConnection() async {
    // Simulate network check
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

  static Future<String?> _getInputData() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'sample-input';
  }

  static Future<String?> _performNetworkOperation(String input) async {
    await Future.delayed(Duration(milliseconds: 500));
    return 'network-result';
  }

  static Future<String?> _performDatabaseOperation(String input) async {
    await Future.delayed(Duration(milliseconds: 300));
    return 'db-result';
  }

  static Future<String?> _performStorageOperation(String input) async {
    await Future.delayed(Duration(milliseconds: 400));
    return 'storage-result';
  }
}

/// Example widget showing how to use error handling in UI components
class ErrorHandlingExampleWidget extends StatefulWidget {
  @override
  _ErrorHandlingExampleWidgetState createState() => _ErrorHandlingExampleWidgetState();
}

class _ErrorHandlingExampleWidgetState extends State<ErrorHandlingExampleWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error Handling Examples')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : () => _testAuthError(),
              child: Text('Test Authentication Error'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _testNetworkError(),
              child: Text('Test Network Error'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _testValidationError(),
              child: Text('Test Validation Error'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _testDatabaseError(),
              child: Text('Test Database Error'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _testStorageError(),
              child: Text('Test Storage Error'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _showErrorReport(),
              child: Text('Show Error Report'),
            ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAuthError() async {
    setState(() => _isLoading = true);
    try {
      await ExampleService.signInExample('wrong@example.com', 'password', context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testNetworkError() async {
    setState(() => _isLoading = true);
    try {
      final error = AppError.network('Connection timeout');
      ErrorHandler.handleError(error, context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testValidationError() async {
    setState(() => _isLoading = true);
    try {
      final error = AppError.validation('email', 'Invalid email format');
      ErrorHandler.handleError(error, context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDatabaseError() async {
    setState(() => _isLoading = true);
    try {
      await ExampleService.fetchUserDataExample('invalid-uid', context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testStorageError() async {
    setState(() => _isLoading = true);
    try {
      await ExampleService.uploadFileExample('corrupt-file.jpg', context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorReport() {
    final report = ErrorHandler.generateErrorReport();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error Report'),
        content: SingleChildScrollView(
          child: Text(report, style: TextStyle(fontFamily: 'monospace')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              ErrorHandler.clearErrorLog();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error log cleared')),
              );
            },
            child: Text('Clear Log'),
          ),
        ],
      ),
    );
  }
}