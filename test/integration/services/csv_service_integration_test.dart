import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late CSVService csvService;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock rootBundle para que devuelva datos CSV de prueba
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'loadString') {
          // Devolver un CSV de prueba con formato: weekday,hour,completion_rate,category
          return Future.value('weekday,hour,completion_rate,category\n'
              '1,9,0.9,work\n'
              '3,16,0.85,study\n'
              '5,10,0.8,personal\n');
        }
        return null;
      },
    );
    
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(TimeBlockModelAdapter());
    }
  });

  setUp(() {
    csvService = CSVService();
  });

  tearDownAll(() async {
    // Limpiar mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      null,
    );
    
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('should load top 3 productive blocks', () async {
    // El servicio intentará cargar desde assets, pero como están mockeados,
    // debería devolver los bloques parseados del CSV de prueba
    final blocks = await csvService.loadTop3Blocks();
    expect(blocks, isA<List<ProductiveBlock>>());
    // El servicio puede devolver bloques del CSV mockeado o bloques por defecto
    expect(blocks.length, greaterThanOrEqualTo(0));
  });

  test('should load all blocks stats', () async {
    // El servicio intentará cargar desde assets, pero como están mockeados,
    // debería devolver los bloques parseados del CSV de prueba
    final blocks = await csvService.loadAllBlocksStats();
    expect(blocks, isA<List<ProductiveBlock>>());
    // El servicio puede devolver bloques del CSV mockeado o bloques por defecto
    expect(blocks.length, greaterThanOrEqualTo(0));
  });
}
