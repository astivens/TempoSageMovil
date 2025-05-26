import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/duplicate_timeblock_cleaner.dart';

/// Servicio para manejar migraciones y limpieza de datos
///
/// Este servicio se encarga de ejecutar migraciones automáticas
/// cuando se detectan cambios en la estructura de datos o problemas
class MigrationService {
  static const String _lastMigrationKey = 'last_migration_version';
  static const int _currentMigrationVersion = 1;

  /// Ejecuta todas las migraciones necesarias
  static Future<void> runMigrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMigration = prefs.getInt(_lastMigrationKey) ?? 0;

      debugPrint('🔄 Verificando migraciones...');
      debugPrint('   📊 Última migración: $lastMigration');
      debugPrint('   🎯 Migración actual: $_currentMigrationVersion');

      if (lastMigration < _currentMigrationVersion) {
        debugPrint('🚀 Ejecutando migraciones...');

        // Ejecutar migraciones en orden
        if (lastMigration < 1) {
          await _migrationV1CleanDuplicateTimeBlocks();
        }

        // Actualizar versión de migración
        await prefs.setInt(_lastMigrationKey, _currentMigrationVersion);
        debugPrint('✅ Migraciones completadas');
      } else {
        debugPrint('✨ No se requieren migraciones');
      }
    } catch (e) {
      debugPrint('❌ Error ejecutando migraciones: $e');
    }
  }

  /// Migración V1: Limpia time blocks duplicados
  static Future<void> _migrationV1CleanDuplicateTimeBlocks() async {
    try {
      debugPrint('🧹 Migración V1: Limpiando time blocks duplicados...');

      // Primero analizar el problema
      final stats = await DuplicateTimeBlockCleaner.analyzeDuplicates();

      if (stats['totalDuplicates'] != null && stats['totalDuplicates']! > 0) {
        debugPrint(
            '🔍 Encontrados ${stats['totalDuplicates']} duplicados en ${stats['datesWithDuplicates']} fechas');

        // Ejecutar limpieza
        final removedCount =
            await DuplicateTimeBlockCleaner.cleanAllDuplicates();
        debugPrint(
            '✅ Migración V1 completada: $removedCount duplicados eliminados');
      } else {
        debugPrint('✨ No se encontraron duplicados que limpiar');
      }
    } catch (e) {
      debugPrint('❌ Error en migración V1: $e');
    }
  }

  /// Fuerza la re-ejecución de todas las migraciones
  static Future<void> forceMigrations() async {
    try {
      debugPrint('🔄 Forzando re-ejecución de migraciones...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastMigrationKey);
      await runMigrations();
    } catch (e) {
      debugPrint('❌ Error forzando migraciones: $e');
    }
  }

  /// Ejecuta una limpieza manual de duplicados
  static Future<int> manualDuplicateCleanup() async {
    try {
      debugPrint('🧹 Ejecutando limpieza manual de duplicados...');

      // Mostrar estadísticas antes
      final statsBefore = await DuplicateTimeBlockCleaner.analyzeDuplicates();

      if (statsBefore['totalDuplicates'] != null &&
          statsBefore['totalDuplicates']! > 0) {
        // Ejecutar limpieza
        final removedCount =
            await DuplicateTimeBlockCleaner.cleanAllDuplicates();

        // Mostrar estadísticas después
        final statsAfter = await DuplicateTimeBlockCleaner.analyzeDuplicates();

        debugPrint('📊 Limpieza manual completada:');
        debugPrint('   🗑️ Eliminados: $removedCount duplicados');
        debugPrint(
            '   ✅ Restantes: ${statsAfter['totalDuplicates'] ?? 0} duplicados');

        return removedCount;
      } else {
        debugPrint('✨ No se encontraron duplicados para limpiar');
        return 0;
      }
    } catch (e) {
      debugPrint('❌ Error en limpieza manual: $e');
      return 0;
    }
  }

  /// Verifica el estado del sistema y reporta problemas
  static Future<Map<String, dynamic>> systemHealthCheck() async {
    try {
      debugPrint('🔍 Ejecutando verificación de salud del sistema...');

      final health = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'duplicates': {},
        'migrations': {},
        'status': 'healthy',
        'warnings': <String>[],
        'errors': <String>[],
      };

      // Verificar duplicados
      final duplicateStats =
          await DuplicateTimeBlockCleaner.analyzeDuplicates();
      health['duplicates'] = duplicateStats;

      if (duplicateStats['totalDuplicates'] != null &&
          duplicateStats['totalDuplicates']! > 0) {
        health['warnings'].add(
            'Se encontraron ${duplicateStats['totalDuplicates']} time blocks duplicados');
        health['status'] = 'warning';
      }

      // Verificar migraciones
      final prefs = await SharedPreferences.getInstance();
      final lastMigration = prefs.getInt(_lastMigrationKey) ?? 0;
      health['migrations'] = {
        'lastExecuted': lastMigration,
        'current': _currentMigrationVersion,
        'needsMigration': lastMigration < _currentMigrationVersion,
      };

      if (lastMigration < _currentMigrationVersion) {
        health['warnings'].add('Hay migraciones pendientes de ejecutar');
        health['status'] = 'warning';
      }

      debugPrint('📊 Verificación de salud completada: ${health['status']}');
      return health;
    } catch (e) {
      debugPrint('❌ Error en verificación de salud: $e');
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'error',
        'errors': ['Error ejecutando verificación: $e'],
      };
    }
  }

  /// Obtiene información sobre las migraciones
  static Future<Map<String, dynamic>> getMigrationInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMigration = prefs.getInt(_lastMigrationKey) ?? 0;

      return {
        'lastExecutedVersion': lastMigration,
        'currentVersion': _currentMigrationVersion,
        'needsMigration': lastMigration < _currentMigrationVersion,
        'availableMigrations': [
          {
            'version': 1,
            'name': 'Clean Duplicate TimeBlocks',
            'description':
                'Elimina time blocks duplicados que pueden haberse creado por errores de sincronización',
            'executed': lastMigration >= 1,
          },
        ],
      };
    } catch (e) {
      debugPrint('❌ Error obteniendo información de migraciones: $e');
      return {};
    }
  }
}
