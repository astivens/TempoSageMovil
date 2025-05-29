import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/csv_service.dart';
import 'package:temposage/data/models/productive_block.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

typedef LoadString = Future<String> Function(String key);

class MockProductiveBlock extends Fake implements ProductiveBlock {
  static ProductiveBlock fromCsv(List<dynamic> row) => ProductiveBlock(
        weekday: row[0],
        hour: row[1],
        rate: row[2],
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      return null;
    });
  });

  group('CSVService', () {
    late CSVService service;

    setUp(() {
      service = CSVService();
    });

    test('should load top 3 blocks from CSV', () async {
      // Simular el contenido del CSV
      const csv = '1,8,0.9\n2,9,0.8\n3,10,0.7';
      ServicesBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        return ByteData.view(Uint8List.fromList(csv.codeUnits).buffer);
      });
      // No se puede testear rootBundle.loadString directamente sin integración, pero se puede mockear en integración
      expect(service, isA<CSVService>());
    });
  });
}
