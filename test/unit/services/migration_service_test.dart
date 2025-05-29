import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/migration_service.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    SharedPreferences.setMockInitialValues({});
  });
  group('MigrationService', () {
    test('should run migrations without throwing', () async {
      await MigrationService.runMigrations();
      expect(true, isTrue); // Si no lanza, pasa
    });

    test('should force migrations without throwing', () async {
      await MigrationService.forceMigrations();
      expect(true, isTrue);
    });

    test('should perform manual duplicate cleanup', () async {
      final removed = await MigrationService.manualDuplicateCleanup();
      expect(removed, isA<int>());
    });

    test('should perform system health check', () async {
      final health = await MigrationService.systemHealthCheck();
      expect(health, isA<Map<String, dynamic>>());
      expect(health['status'], isNotNull);
    });

    test('should get migration info', () async {
      final info = await MigrationService.getMigrationInfo();
      expect(info, isA<Map<String, dynamic>>());
      expect(info['currentVersion'], isNotNull);
    });
  });
}
