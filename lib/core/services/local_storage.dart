import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here
    // await Hive.openBox('userBox');
    // await Hive.openBox('settingsBox');
  }

  static Future<void> saveData<T>(String boxName, String key, T value) async {
    final box = await Hive.openBox<T>(boxName);
    await box.put(key, value);
  }

  static Future<T?> getData<T>(String boxName, String key) async {
    final box = await Hive.openBox<T>(boxName);
    return box.get(key);
  }

  static Future<void> deleteData(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }

  static Future<void> clearBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
