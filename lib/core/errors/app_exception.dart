/// Clase base para todas las excepciones de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (code: $code)' : ''}';
  }
}

/// Excepción para errores de repositorio (base de datos, almacenamiento)
class RepositoryException extends AppException {
  const RepositoryException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'repository_error',
          originalError: originalError,
        );
}

/// Excepción para errores de servicio (lógica de negocio)
class ServiceException extends AppException {
  const ServiceException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'service_error',
          originalError: originalError,
        );
}

/// Excepción para errores de validación
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'validation_error',
          originalError: originalError,
        );
}
