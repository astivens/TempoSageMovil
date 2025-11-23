import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/migration_service.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(TimeBlockModelAdapter());
    }
  });

  setUp(() {
    // Si necesitas limpiar o preparar algo antes de cada test, hazlo aquí
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('should run migrations and affect data', () async {
    // Insertar duplicados previos a la migración
    final box = await Hive.openBox<TimeBlockModel>('timeblocks');
    await box.clear();
    final now = DateTime.now();
    final block = TimeBlockModel.create(
      title: 'Duplicado',
      description: 'Bloque duplicado',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
      category: 'work',
      color: '#FF0000',
    );
    await box.add(block);
    await box.add(block.copyWith(id: 'otro_id'));
    // Ejecutar migración
    await MigrationService.runMigrations();
    // Verificar que solo queda un bloque
    final allBlocks = box.values.where((b) => b.title == 'Duplicado').toList();
    expect(allBlocks.length, 1);
  });
}
