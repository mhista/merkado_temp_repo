import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  GoogleAuthException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;

  /// V7.0: Convert new exception types to user-friendly messages
  factory GoogleAuthException.fromGoogleSignInException(
    GoogleSignInException exception,
  ) {
    final messages = {
      'canceled': 'Sign-in was cancelled. Please try again if you want to continue.',
      'interrupted': 'Sign-in was interrupted. Please try again.',
      'clientConfigurationError': 'Configuration issue with Google Sign-In. Contact support.',
      'providerConfigurationError': 'Google Sign-In unavailable. Try again later.',
      'uiUnavailable': 'Google Sign-In UI unavailable. Try again later.',
      'userMismatch': 'Account issue. Please sign out and try again.',
    };

    return GoogleAuthException(
      message: messages[exception.code.name] ?? 'Unexpected error during Google Sign-In.',
      code: exception.code.name,
      originalError: exception,
    );
  }

  factory GoogleAuthException.notInitialized() => GoogleAuthException(
        message: 'Google Sign-In not initialized. Call initialize() first.',
        code: 'not_initialized',
      );

  factory GoogleAuthException.platformNotSupported() => GoogleAuthException(
        message: 'Platform not supported.',
        code: 'platform_not_supported',
      );

  factory GoogleAuthException.generic(String msg, [dynamic err]) =>
      GoogleAuthException(message: msg, originalError: err);
}