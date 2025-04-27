import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static final Map<String, Box> _openBoxes = {};

  static Future<void> init() async {
    await Hive.initFlutter();
    debugPrint('Hive inicializado');
  }

  static Future<Box<T>> _getBox<T>(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName] as Box<T>;
    }

    debugPrint('Abriendo box: $boxName');
    final box = await Hive.openBox<T>(boxName);
    _openBoxes[boxName] = box;
    return box;
  }

  static Future<void> saveData<T>(String boxName, String key, T value) async {
    final box = await _getBox<T>(boxName);
    await box.put(key, value);
  }

  static Future<T?> getData<T>(String boxName, String key) async {
    final box = await _getBox<T>(boxName);
    return box.get(key);
  }

  static Future<List<T>> getAllData<T>(String boxName) async {
    final box = await _getBox<T>(boxName);
    return box.values.toList();
  }

  static Future<void> deleteData(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  static Future<void> clearBox(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  static Future<void> closeBox(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      final box = _openBoxes[boxName]!;
      await box.close();
      _openBoxes.remove(boxName);
    }
  }

  static Future<void> closeAll() async {
    for (final box in _openBoxes.values) {
      await box.close();
    }
    _openBoxes.clear();
  }
}
