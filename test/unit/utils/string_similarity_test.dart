import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/utils/string_similarity.dart';

void main() {
  group('StringSimilarity - levenshteinDistance', () {
    test('debería retornar 0 para strings idénticos', () {
      expect(StringSimilarity.levenshteinDistance('hello', 'hello'), 0);
      expect(StringSimilarity.levenshteinDistance('', ''), 0);
    });

    test('debería retornar la longitud del segundo string si el primero está vacío',
        () {
      expect(StringSimilarity.levenshteinDistance('', 'hello'), 5);
      expect(StringSimilarity.levenshteinDistance('', 'test'), 4);
    });

    test('debería retornar la longitud del primer string si el segundo está vacío',
        () {
      expect(StringSimilarity.levenshteinDistance('hello', ''), 5);
      expect(StringSimilarity.levenshteinDistance('test', ''), 4);
    });

    test('debería calcular correctamente la distancia entre strings diferentes', () {
      expect(StringSimilarity.levenshteinDistance('kitten', 'sitting'), 3);
      expect(StringSimilarity.levenshteinDistance('saturday', 'sunday'), 3);
      expect(StringSimilarity.levenshteinDistance('hello', 'hallo'), 1);
    });

    test('debería manejar strings con caracteres especiales', () {
      expect(StringSimilarity.levenshteinDistance('café', 'cafe'), 1);
      expect(StringSimilarity.levenshteinDistance('naïve', 'naive'), 1);
    });
  });

  group('StringSimilarity - similarity', () {
    test('debería retornar 1.0 para strings idénticos', () {
      expect(StringSimilarity.similarity('hello', 'hello'), 1.0);
      expect(StringSimilarity.similarity('TEST', 'test'), 1.0);
    });

    test('debería retornar 1.0 para strings vacíos', () {
      expect(StringSimilarity.similarity('', ''), 1.0);
    });

    test('debería calcular similitud correctamente para strings diferentes', () {
      final similarity1 = StringSimilarity.similarity('hello', 'hallo');
      expect(similarity1, greaterThan(0.0));
      expect(similarity1, lessThan(1.0));

      final similarity2 = StringSimilarity.similarity('kitten', 'sitting');
      expect(similarity2, greaterThan(0.0));
      expect(similarity2, lessThan(1.0));
    });

    test('debería ser case-insensitive', () {
      expect(StringSimilarity.similarity('Hello', 'HELLO'), 1.0);
      expect(StringSimilarity.similarity('Test', 'test'), 1.0);
    });

    test('debería retornar 0.0 para strings completamente diferentes', () {
      final similarity = StringSimilarity.similarity('abc', 'xyz');
      expect(similarity, lessThan(0.5));
    });
  });

  group('StringSimilarity - findBestMatch', () {
    test('debería retornar null si la lista de candidatos está vacía', () {
      expect(StringSimilarity.findBestMatch('test', []), isNull);
    });

    test('debería encontrar la mejor coincidencia en una lista', () {
      final candidates = ['hello', 'world', 'test', 'example'];
      final result = StringSimilarity.findBestMatch('test', candidates);
      expect(result, equals('test'));
    });

    test('debería encontrar la mejor coincidencia parcial', () {
      final candidates = ['hello', 'hallo', 'world'];
      final result = StringSimilarity.findBestMatch('hello', candidates);
      expect(result, equals('hello'));
    });

    test('debería retornar null si ninguna coincidencia supera el umbral', () {
      final candidates = ['abc', 'def', 'ghi'];
      final result = StringSimilarity.findBestMatch('xyz', candidates);
      expect(result, isNull);
    });

    test('debería manejar coincidencias case-insensitive', () {
      final candidates = ['Hello', 'World', 'Test'];
      final result = StringSimilarity.findBestMatch('hello', candidates);
      expect(result, equals('Hello'));
    });

    test('debería encontrar la mejor coincidencia entre múltiples opciones', () {
      final candidates = ['activity', 'actividad', 'action', 'active'];
      final result = StringSimilarity.findBestMatch('activity', candidates);
      expect(result, equals('activity'));
    });
  });
}

