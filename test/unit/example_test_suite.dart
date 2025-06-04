import 'package:flutter_test/flutter_test.dart';

/// Este archivo de prueba está diseñado para demostrar todas las características
/// del sistema de informes de pruebas de TempoSage.
void main() {
  group('Ejemplos de pruebas exitosas', () {
    test('suma simple', () {
      expect(2 + 2, equals(4));
    });

    test('comparación de strings', () {
      expect('Hola Mundo', contains('Mundo'));
    });

    test('operaciones con listas', () {
      final lista = [1, 2, 3, 4, 5];
      expect(lista, hasLength(5));
      expect(lista, contains(3));
      expect(lista.first, equals(1));
      expect(lista.last, equals(5));
    });
  });

  group('Ejemplos de pruebas fallidas', () {
    test('fallo de igualdad', () {
      // Esta prueba fallará
      expect(2 + 2, equals(5), reason: 'La suma de 2+2 debería ser 4, no 5');
    });

    test('fallo en tipo de datos', () {
      // Esta prueba fallará
      final valor = 42;
      expect(valor, isA<String>(), reason: 'El valor debería ser un String');
    });
  });

  group('Ejemplos de pruebas omitidas', () {
    test('prueba omitida explícitamente', () {
      expect(true, isFalse);
    }, skip: 'Esta prueba se omite a propósito');
  });

  group('Ejemplos con tiempos de ejecución', () {
    test('prueba con retraso corto', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(true, isTrue);
    });

    test('prueba con retraso medio', () async {
      await Future.delayed(const Duration(milliseconds: 250));
      expect(true, isTrue);
    });

    test('prueba con retraso largo', () async {
      await Future.delayed(const Duration(milliseconds: 500));
      expect(true, isTrue);
    });
  });

  group('Pruebas con datos complejos', () {
    test('prueba con mapa anidado', () {
      final usuario = {
        'nombre': 'Juan',
        'edad': 30,
        'direccion': {
          'calle': 'Calle Principal',
          'numero': 123,
          'ciudad': 'Ciudad Ejemplo',
          'coordenadas': [40.7128, -74.0060],
        },
        'telefonos': [
          {'tipo': 'casa', 'numero': '555-1234'},
          {'tipo': 'trabajo', 'numero': '555-5678'},
        ],
      };

      expect(usuario['nombre'], equals('Juan'));
      expect((usuario['direccion'] as Map)['ciudad'], equals('Ciudad Ejemplo'));
      expect((usuario['telefonos'] as List)[1]['numero'], equals('555-5678'));

      // Esta aserción fallará para demostrar el reporte detallado
      expect((usuario['direccion'] as Map)['codigo_postal'], isNotNull,
          reason: 'Debería existir el código postal');
    });
  });

  group('Pruebas con excepciones', () {
    test('verifica que se lance una excepción', () {
      expect(() => throw Exception('Error planeado'), throwsException);
    });

    test('verifica que se lance un tipo específico de error', () {
      // Esta prueba fallará para mostrar el mensaje de error
      expect(() => throw ArgumentError('Argumento inválido'),
          throwsA(isA<FormatException>()));
    });
  });
}
