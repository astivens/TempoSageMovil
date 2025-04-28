import 'package:flutter/material.dart';
import '../errors/app_exception.dart';
import 'logger.dart';

/// Clase para gestionar errores de manera centralizada en la aplicación.
/// Proporciona métodos para registrar, mostrar y analizar errores.
class ErrorHandler {
  static final Logger _logger = Logger.instance;

  /// Registra un error con contexto y detalles.
  ///
  /// Utiliza diferentes niveles de log según la gravedad.
  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      _logger.exception(error, stackTrace: stackTrace);
    } else {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Muestra un mensaje de error en un SnackBar.
  static void showErrorSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Muestra un mensaje de éxito en un SnackBar.
  static void showSuccessSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Muestra un diálogo de error con detalles y acciones.
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionLabel ?? 'Reintentar'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Procesa una excepción y devuelve un mensaje amigable para el usuario
  static String getFriendlyErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return 'Error de validación: ${error.message}';
    } else if (error is RepositoryException) {
      return 'Error de datos: ${error.message}';
    } else if (error is ServiceException) {
      return 'Error de servicio: ${error.message}';
    } else if (error is AppException) {
      return error.message;
    } else {
      return 'Ha ocurrido un error inesperado';
    }
  }
}
