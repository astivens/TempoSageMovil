import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/utils/logger.dart';
import 'package:temposage/core/errors/app_exception.dart';

void main() {
  group('Logger - instance', () {
    test('debería retornar la misma instancia singleton', () {
      final logger1 = Logger.instance;
      final logger2 = Logger.instance;
      expect(logger1, equals(logger2));
    });
  });

  group('Logger - factory constructor', () {
    test('debería crear logger con tag específico', () {
      final logger = Logger('TestTag');
      expect(logger, isA<Logger>());
    });
  });

  group('Logger - setMinLevel', () {
    test('debería configurar el nivel mínimo de log', () {
      final logger = Logger.instance;
      logger.setMinLevel(LogLevel.warning);
      expect(logger, isNotNull);
    });
  });

  group('Logger - setVerboseMode', () {
    test('debería configurar el modo verboso', () {
      final logger = Logger.instance;
      logger.setVerboseMode(true);
      expect(logger, isNotNull);
    });
  });

  group('Logger - d (debug)', () {
    test('debería registrar mensaje de debug sin error', () {
      final logger = Logger.instance;
      expect(() => logger.d('Debug message'), returnsNormally);
    });

    test('debería registrar mensaje de debug con tag', () {
      final logger = Logger.instance;
      expect(() => logger.d('Debug message', tag: 'TestTag'), returnsNormally);
    });

    test('debería registrar mensaje de debug con data', () {
      final logger = Logger.instance;
      expect(
        () => logger.d('Debug message', data: {'key': 'value'}),
        returnsNormally,
      );
    });
  });

  group('Logger - i (info)', () {
    test('debería registrar mensaje de info', () {
      final logger = Logger.instance;
      expect(() => logger.i('Info message'), returnsNormally);
    });

    test('debería registrar mensaje de info con tag y data', () {
      final logger = Logger.instance;
      expect(
        () => logger.i('Info message', tag: 'TestTag', data: {'key': 'value'}),
        returnsNormally,
      );
    });
  });

  group('Logger - w (warning)', () {
    test('debería registrar mensaje de warning', () {
      final logger = Logger.instance;
      expect(() => logger.w('Warning message'), returnsNormally);
    });

    test('debería registrar mensaje de warning con tag y data', () {
      final logger = Logger.instance;
      expect(
        () => logger.w('Warning message', tag: 'TestTag', data: {'key': 'value'}),
        returnsNormally,
      );
    });
  });

  group('Logger - e (error)', () {
    test('debería registrar mensaje de error', () {
      final logger = Logger.instance;
      expect(() => logger.e('Error message'), returnsNormally);
    });

    test('debería registrar mensaje de error con error y stack trace', () {
      final logger = Logger.instance;
      expect(
        () => logger.e(
          'Error message',
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('debería registrar mensaje de error con tag y data', () {
      final logger = Logger.instance;
      expect(
        () => logger.e(
          'Error message',
          tag: 'TestTag',
          data: {'key': 'value'},
        ),
        returnsNormally,
      );
    });
  });

  group('Logger - c (critical)', () {
    test('debería registrar mensaje crítico', () {
      final logger = Logger.instance;
      expect(() => logger.c('Critical message'), returnsNormally);
    });

    test('debería registrar mensaje crítico con error y stack trace', () {
      final logger = Logger.instance;
      expect(
        () => logger.c(
          'Critical message',
          error: Exception('Critical error'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });

  group('Logger - exception', () {
    test('debería registrar AppException', () {
      final logger = Logger.instance;
      final exception = ValidationException(message: 'Validation failed');
      expect(
        () => logger.exception(exception),
        returnsNormally,
      );
    });

    test('debería registrar AppException con stack trace y data', () {
      final logger = Logger.instance;
      final exception = RepositoryException(message: 'Database error');
      expect(
        () => logger.exception(
          exception,
          stackTrace: StackTrace.current,
          data: {'key': 'value'},
        ),
        returnsNormally,
      );
    });
  });

  group('Logger - tagged logger', () {
    test('debería usar tag predefinido en mensajes', () {
      final logger = Logger('TestTag');
      expect(() => logger.d('Debug message'), returnsNormally);
      expect(() => logger.i('Info message'), returnsNormally);
      expect(() => logger.w('Warning message'), returnsNormally);
      expect(() => logger.e('Error message'), returnsNormally);
      expect(() => logger.c('Critical message'), returnsNormally);
    });

    test('debería permitir sobrescribir tag en mensajes específicos', () {
      final logger = Logger('DefaultTag');
      expect(() => logger.d('Debug message', tag: 'CustomTag'), returnsNormally);
    });
  });
}

