import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:temposage/core/utils/error_handler.dart';
import 'package:temposage/core/errors/app_exception.dart';

void main() {
  group('ErrorHandler - logError', () {
    test('debería registrar error sin excepción', () {
      expect(() => ErrorHandler.logError('Test error', null, null), returnsNormally);
    });

    test('debería registrar error con excepción genérica', () {
      expect(
        () => ErrorHandler.logError('Test error', Exception('Test'), null),
        returnsNormally,
      );
    });

    test('debería registrar error con AppException', () {
      final exception = ValidationException(message: 'Validation failed');
      expect(
        () => ErrorHandler.logError('Test error', exception, null),
        returnsNormally,
      );
    });

    test('debería registrar error con stack trace', () {
      final stackTrace = StackTrace.current;
      expect(
        () => ErrorHandler.logError('Test error', Exception('Test'), stackTrace),
        returnsNormally,
      );
    });
  });

  group('ErrorHandler - getFriendlyErrorMessage', () {
    test('debería retornar mensaje amigable para ValidationException', () {
      final exception = ValidationException(message: 'Invalid input');
      final message = ErrorHandler.getFriendlyErrorMessage(exception);
      expect(message, contains('Error de validación'));
      expect(message, contains('Invalid input'));
    });

    test('debería retornar mensaje amigable para RepositoryException', () {
      final exception = RepositoryException(message: 'Database error');
      final message = ErrorHandler.getFriendlyErrorMessage(exception);
      expect(message, contains('Error de datos'));
      expect(message, contains('Database error'));
    });

    test('debería retornar mensaje amigable para ServiceException', () {
      final exception = ServiceException(message: 'Service unavailable');
      final message = ErrorHandler.getFriendlyErrorMessage(exception);
      expect(message, contains('Error de servicio'));
      expect(message, contains('Service unavailable'));
    });

    test('debería retornar mensaje amigable para AppException genérica', () {
      final exception = RepositoryException(message: 'Generic error', code: 'CODE001');
      final message = ErrorHandler.getFriendlyErrorMessage(exception);
      expect(message, contains('Generic error'));
    });

    test('debería retornar mensaje genérico para excepciones desconocidas', () {
      final message = ErrorHandler.getFriendlyErrorMessage(Exception('Unknown'));
      expect(message, equals('Ha ocurrido un error inesperado'));
    });
  });

  group('ErrorHandler - showErrorSnackBar', () {
    testWidgets('debería mostrar SnackBar con mensaje de error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandler.showErrorSnackBar(context, 'Error message');
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('debería mostrar SnackBar con color de fondo personalizado',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandler.showErrorSnackBar(
                      context,
                      'Error message',
                      backgroundColor: Colors.blue,
                    );
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();
      expect(find.text('Error message'), findsOneWidget);
    });
  });

  group('ErrorHandler - showSuccessSnackBar', () {
    testWidgets('debería mostrar SnackBar con mensaje de éxito', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandler.showSuccessSnackBar(context, 'Success message');
                  },
                  child: const Text('Test'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();
      expect(find.text('Success message'), findsOneWidget);
    });
  });

  group('ErrorHandler - showErrorDialog', () {
    testWidgets('debería mostrar diálogo de error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      ErrorHandler.showErrorDialog(
        tester.element(find.text('Test')),
        'Error Title',
        'Error message',
      );

      await tester.pump();
      expect(find.text('Error Title'), findsOneWidget);
      expect(find.text('Error message'), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget);
    });

    testWidgets('debería mostrar diálogo con acción personalizada', (tester) async {
      bool actionCalled = false;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      ErrorHandler.showErrorDialog(
        tester.element(find.text('Test')),
        'Error Title',
        'Error message',
        actionLabel: 'Reintentar',
        onAction: () {
          actionCalled = true;
        },
      );

      await tester.pump();
      expect(find.text('Reintentar'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(actionCalled, isTrue);
    });
  });
}

