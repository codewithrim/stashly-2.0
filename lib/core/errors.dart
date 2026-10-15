/// User-friendly exception types mapping system/database errors to clear messages.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(
      [super.message =
          'Unable to connect. Please check your internet connection and try again.']);
}

class AuthException extends AppException {
  const AuthException(
      [super.message =
          'Authentication failed. Please check your credentials.']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(
      [super.message = 'The requested item was not found.']);
}

class ConflictException extends AppException {
  const ConflictException(
      [super.message = 'This item was modified on another device.']);
}

class StorageException extends AppException {
  const StorageException(
      [super.message = 'Failed to upload or retrieve attachment.']);
}

class UnknownException extends AppException {
  const UnknownException(
      [super.message = 'An unexpected error occurred. Please try again.']);
}
