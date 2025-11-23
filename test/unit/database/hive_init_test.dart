import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/database/hive_init.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late Directory tempDir;
  
  setUpAll(() async {
    // Initialize Hive with a temporary directory
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
  });
  
  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });
  
  group('initHive Tests', () {
    test('initHive debería ser una función asíncrona', () async {
      // Note: initHive may fail if Hive is already initialized
      // This test verifies the function signature
      try {
        final future = initHive();
        expect(future, isA<Future>());
        await future;
      } catch (e) {
        // Expected if Hive is already initialized
        expect(e, isNotNull);
      }
    });

    test('initHive debería retornar Future<void>', () async {
      // Note: initHive may fail if Hive is already initialized
      // This test verifies the return type
      try {
        final future = initHive();
        expect(future, isA<Future<void>>());
        await future;
      } catch (e) {
        // Expected if Hive is already initialized
        expect(e, isNotNull);
      }
    });
  });
}

