import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

/// Servicio para gestionar el almacenamiento local con Hive
class LocalStorage {
  static final Map<String, Box> _openBoxes = {};
  static final Logger _logger = Logger.instance;

  /// Inicializa Hive para almacenamiento local
  static Future<void> init() async {
    await Hive.initFlutter();
    _logger.i('Hive inicializado', tag: 'LocalStorage');
  }

  /// Obtiene una caja (box) de Hive, cacheando el resultado para mejorar rendimiento
  static Future<Box<T>> _getBox<T>(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName] as Box<T>;
    }

    _logger.d('Abriendo box: $boxName', tag: 'LocalStorage');
    final box = await Hive.openBox<T>(boxName);
    _openBoxes[boxName] = box;
    return box;
  }

  /// Obtiene una caja (box) de Hive para su uso en repositorios
  /// Método público que llama al privado _getBox
  static Future<Box<T>> getBox<T>(String boxName) async {
    return _getBox<T>(boxName);
  }

  /// Guarda un valor en una caja (box) especificada
  static Future<void> saveData<T>(String boxName, String key, T value) async {
    final box = await _getBox<T>(boxName);
    await box.put(key, value);
  }

  /// Obtiene un valor de una caja (box) especificada
  static Future<T?> getData<T>(String boxName, String key) async {
    final box = await _getBox<T>(boxName);
    return box.get(key);
  }

  /// Obtiene todos los valores de una caja (box) especificada
  static Future<List<T>> getAllData<T>(String boxName) async {
    final box = await _getBox<T>(boxName);
    return box.values.toList();
  }

  /// Elimina un valor de una caja (box) especificada
  static Future<void> deleteData(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  /// Limpia todos los valores de una caja (box) especificada
  static Future<void> clearBox(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  /// Cierra una caja (box) específica y libera recursos
  static Future<void> closeBox(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      final box = _openBoxes[boxName]!;
      await box.close();
      _openBoxes.remove(boxName);
    }
  }

  /// Cierra todas las cajas (boxes) abiertas y libera recursos
  static Future<void> closeAll() async {
    for (final box in _openBoxes.values) {
      await box.close();
    }
    _openBoxes.clear();
  }
}
