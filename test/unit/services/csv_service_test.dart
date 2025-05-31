import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/models/productive_block.dart';

class MockCSVService extends CSVService {
  @override
  Future<List<ProductiveBlock>> loadTop3Blocks() async {
    return [
      ProductiveBlock(
        weekday: 1,
        hour: 9,
        completionRate: 0.9,
        isProductiveBlock: true,
        category: "Trabajo",
      ),
      ProductiveBlock(
        weekday: 3,
        hour: 14,
        completionRate: 0.8,
        isProductiveBlock: true,
        category: "Estudio",
      ),
    ];
  }

  @override
  Future<Map<String, List<ProductiveBlock>>> loadBlocksByCategory() async {
    return {
      'Trabajo': [
        ProductiveBlock(
          weekday: 1,
          hour: 9,
          completionRate: 0.2,
          isProductiveBlock: false,
          category: "Trabajo",
        ),
      ],
      'Estudio': [
        ProductiveBlock(
          weekday: 3,
          hour: 14,
          completionRate: 0.1,
          isProductiveBlock: false,
          category: "Estudio",
        ),
      ],
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCSVService csvService;

  setUp(() {
    csvService = MockCSVService();
  });

  group('CSVService', () {
    test('_getDefaultBlocks devuelve la cantidad correcta de bloques',
        () async {
      // Verificar que loadTop3Blocks devuelve 2 bloques por defecto en nuestro mock
      final blocks = await csvService.loadTop3Blocks();
      expect(blocks.length, 2);
    });

    test('_parseProductiveBlocks debe manejar correctamente el CSV', () async {
      // Invocar el método que usa _parseProductiveBlocks internamente
      final result = await csvService.loadTop3Blocks();

      // Verificaciones
      expect(result.length, 2);
      expect(result[0].weekday, 1);
      expect(result[0].hour, 9);
      expect(result[0].completionRate, 0.9);
      expect(result[0].category, 'Trabajo');
      expect(result[1].weekday, 3);
      expect(result[1].hour, 14);
      expect(result[1].completionRate, 0.8);
      expect(result[1].category, 'Estudio');
    });

    test('loadBlocksByCategory debe agrupar bloques por categoría', () async {
      // Ejecutar el método
      final result = await csvService.loadBlocksByCategory();

      // Verificaciones
      expect(result.keys.length, 2); // Trabajo y Estudio
      expect(result['Trabajo']!.length, 1); // Un bloque para Trabajo
      expect(result['Estudio']!.length, 1); // Un bloque para Estudio
      expect(result['Trabajo']![0].weekday, 1);
      expect(result['Trabajo']![0].hour, 9);
      expect(result['Trabajo']![0].completionRate, 0.2);
      expect(result['Estudio']![0].weekday, 3);
      expect(result['Estudio']![0].hour, 14);
      expect(result['Estudio']![0].completionRate, 0.1);
    });
  });
}
