import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/local_storage.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorage Integration Tests', () {
    const testBoxName = 'test_box';
    const testKey = 'test_key';
    const testValue = 'test_value';
    const testIntValue = 42;
    const testDoubleValue = 3.14;
    const testBoolValue = true;

    setUp(() async {
      final directory = await Directory.systemTemp.createTemp();
      await LocalStorage.init(path: directory.path);
    });

    tearDown(() async {
      await LocalStorage.clearBox(testBoxName);
      await LocalStorage.closeBox(testBoxName);
      await LocalStorage.closeAll();
    });

    test('should save and retrieve string data', () async {
      // Arrange & Act
      await LocalStorage.saveData(testBoxName, testKey, testValue);
      final retrievedValue =
          await LocalStorage.getData<String>(testBoxName, testKey);

      // Assert
      expect(retrievedValue, equals(testValue));
    });

    test('should save and retrieve integer data', () async {
      // Arrange & Act
      await LocalStorage.saveData(testBoxName, testKey, testIntValue);
      final retrievedValue =
          await LocalStorage.getData<int>(testBoxName, testKey);

      // Assert
      expect(retrievedValue, equals(testIntValue));
    });

    test('should save and retrieve double data', () async {
      // Arrange & Act
      await LocalStorage.saveData(testBoxName, testKey, testDoubleValue);
      final retrievedValue =
          await LocalStorage.getData<double>(testBoxName, testKey);

      // Assert
      expect(retrievedValue, equals(testDoubleValue));
    });

    test('should save and retrieve boolean data', () async {
      // Arrange & Act
      await LocalStorage.saveData(testBoxName, testKey, testBoolValue);
      final retrievedValue =
          await LocalStorage.getData<bool>(testBoxName, testKey);

      // Assert
      expect(retrievedValue, equals(testBoolValue));
    });

    test('should save and retrieve multiple values', () async {
      // Arrange
      const key1 = 'key1';
      const key2 = 'key2';
      const value1 = 'value1';
      const value2 = 'value2';

      // Act
      await LocalStorage.saveData(testBoxName, key1, value1);
      await LocalStorage.saveData(testBoxName, key2, value2);
      final retrievedValue1 =
          await LocalStorage.getData<String>(testBoxName, key1);
      final retrievedValue2 =
          await LocalStorage.getData<String>(testBoxName, key2);

      // Assert
      expect(retrievedValue1, equals(value1));
      expect(retrievedValue2, equals(value2));
    });

    test('should retrieve all data from box', () async {
      // Arrange
      const key1 = 'key1';
      const key2 = 'key2';
      const value1 = 'value1';
      const value2 = 'value2';

      // Act
      await LocalStorage.saveData(testBoxName, key1, value1);
      await LocalStorage.saveData(testBoxName, key2, value2);
      final allData = await LocalStorage.getAllData<String>(testBoxName);

      // Assert
      expect(allData.length, equals(2));
      expect(allData, contains(value1));
      expect(allData, contains(value2));
    });

    test('should delete specific data', () async {
      // Arrange
      await LocalStorage.saveData(testBoxName, testKey, testValue);

      // Act
      await LocalStorage.deleteData(testBoxName, testKey);
      final retrievedValue =
          await LocalStorage.getData<String>(testBoxName, testKey);

      // Assert
      expect(retrievedValue, isNull);
    });

    test('should clear all data from box', () async {
      // Arrange
      await LocalStorage.saveData(testBoxName, 'key1', 'value1');
      await LocalStorage.saveData(testBoxName, 'key2', 'value2');

      // Act
      await LocalStorage.clearBox(testBoxName);
      final allData = await LocalStorage.getAllData<String>(testBoxName);

      // Assert
      expect(allData, isEmpty);
    });

    test('should handle non-existent key', () async {
      // Act
      final retrievedValue =
          await LocalStorage.getData<String>(testBoxName, 'non_existent_key');

      // Assert
      expect(retrievedValue, isNull);
    });

    test('should maintain data after box reopening', () async {
      // Arrange
      await LocalStorage.saveData(testBoxName, testKey, testValue);

      // Act
      await LocalStorage.closeBox(testBoxName);
      final retrievedValue =
          await LocalStorage.getData<String>(testBoxName, testKey);

      // Assert
      expect(retrievedValue, equals(testValue));
    });

    test('should handle multiple box operations', () async {
      // Arrange
      const box1 = 'box1';
      const box2 = 'box2';
      const key1 = 'key1';
      const key2 = 'key2';
      const value1 = 'value1';
      const value2 = 'value2';

      // Act
      await LocalStorage.saveData(box1, key1, value1);
      await LocalStorage.saveData(box2, key2, value2);
      final retrievedValue1 = await LocalStorage.getData<String>(box1, key1);
      final retrievedValue2 = await LocalStorage.getData<String>(box2, key2);

      // Assert
      expect(retrievedValue1, equals(value1));
      expect(retrievedValue2, equals(value2));

      // Cleanup
      await LocalStorage.clearBox(box1);
      await LocalStorage.clearBox(box2);
      await LocalStorage.closeBox(box1);
      await LocalStorage.closeBox(box2);
    });
  });
}
