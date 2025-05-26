import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../../features/timeblocks/data/models/time_block_model.dart';
import '../../features/timeblocks/data/repositories/time_block_repository.dart';
import '../../features/activities/data/repositories/activity_repository.dart';

/// Utilidad para limpiar time blocks duplicados
///
/// Esta clase proporciona métodos para identificar y eliminar time blocks
/// duplicados que pueden haberse creado por errores en la sincronización
class DuplicateTimeBlockCleaner {
  static final TimeBlockRepository _timeBlockRepo =
      ServiceLocator.instance.timeBlockRepository;
  static final ActivityRepository _activityRepo =
      ServiceLocator.instance.activityRepository;

  /// Limpia todos los time blocks duplicados del sistema
  ///
  /// Retorna el número de duplicados eliminados
  static Future<int> cleanAllDuplicates() async {
    try {
      debugPrint('🧹 Iniciando limpieza de time blocks duplicados...');

      int totalRemoved = 0;
      final now = DateTime.now();

      // Limpiar duplicados para los últimos 30 días y próximos 30 días
      for (int i = -30; i <= 30; i++) {
        final date = now.add(Duration(days: i));
        final removed = await cleanDuplicatesForDate(date);
        totalRemoved += removed;
      }

      debugPrint('✅ Limpieza completada. Total eliminados: $totalRemoved');
      return totalRemoved;
    } catch (e) {
      debugPrint('❌ Error durante la limpieza: $e');
      return 0;
    }
  }

  /// Limpia duplicados para una fecha específica
  ///
  /// Retorna el número de duplicados eliminados
  static Future<int> cleanDuplicatesForDate(DateTime date) async {
    try {
      final timeBlocks = await _timeBlockRepo.getTimeBlocksByDate(date);
      final activities = await _activityRepo.getActivitiesByDate(date);

      if (timeBlocks.length <= 1) {
        return 0; // No hay duplicados posibles
      }

      debugPrint(
          '🔍 Analizando ${timeBlocks.length} time blocks para ${_formatDate(date)}');

      final duplicateGroups = <String, List<TimeBlockModel>>{};
      final toRemove = <TimeBlockModel>[];

      // Agrupar time blocks potencialmente duplicados
      for (final block in timeBlocks) {
        final key = _generateDuplicateKey(block);
        duplicateGroups.putIfAbsent(key, () => []).add(block);
      }

      // Identificar duplicados
      for (final entry in duplicateGroups.entries) {
        final blocks = entry.value;
        if (blocks.length > 1) {
          debugPrint(
              '🔄 Encontrado grupo de ${blocks.length} duplicados: "${blocks.first.title}"');

          // Mantener el mejor time block (más reciente o con mejor información)
          final bestBlock = _selectBestTimeBlock(blocks, activities);
          final duplicates = blocks.where((b) => b.id != bestBlock.id).toList();

          toRemove.addAll(duplicates);
          debugPrint('   ✅ Manteniendo: ${bestBlock.id}');
          debugPrint(
              '   🗑️ Eliminando: ${duplicates.map((b) => b.id).join(', ')}');
        }
      }

      // Eliminar duplicados
      for (final block in toRemove) {
        await _timeBlockRepo.deleteTimeBlock(block.id);
      }

      if (toRemove.isNotEmpty) {
        debugPrint(
            '🧹 Eliminados ${toRemove.length} duplicados para ${_formatDate(date)}');
      }

      return toRemove.length;
    } catch (e) {
      debugPrint('❌ Error limpiando fecha ${_formatDate(date)}: $e');
      return 0;
    }
  }

  /// Genera una clave única para identificar duplicados potenciales
  static String _generateDuplicateKey(TimeBlockModel block) {
    return '${block.title}_${block.startTime.millisecondsSinceEpoch}_${block.endTime.millisecondsSinceEpoch}';
  }

  /// Selecciona el mejor time block de un grupo de duplicados
  static TimeBlockModel _selectBestTimeBlock(
      List<TimeBlockModel> duplicates, List<dynamic> activities) {
    // Priorizar bloques con marcador de actividad generada
    final withActivityMarker = duplicates
        .where((b) => b.description.contains('[ACTIVITY_GENERATED]'))
        .toList();

    if (withActivityMarker.isNotEmpty) {
      // Si hay bloques con marcador, usar el más reciente
      withActivityMarker.sort(
          (a, b) => _extractCreationTime(b).compareTo(_extractCreationTime(a)));
      return withActivityMarker.first;
    }

    // Si no hay marcadores, priorizar por completitud de información
    duplicates.sort((a, b) {
      int scoreA = _calculateBlockScore(a);
      int scoreB = _calculateBlockScore(b);
      return scoreB.compareTo(scoreA); // Mayor score primero
    });

    return duplicates.first;
  }

  /// Extrae el tiempo de creación aproximado de un time block
  static DateTime _extractCreationTime(TimeBlockModel block) {
    // Intentar extraer de la descripción si tiene marcador
    if (block.description.contains('[ACTIVITY_GENERATED]')) {
      try {
        final regex = RegExp(r'ID: (\d+)');
        final match = regex.firstMatch(block.description);
        if (match != null) {
          final timestamp = int.parse(match.group(1)!);
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    // Usar tiempo de inicio como fallback
    return block.startTime;
  }

  /// Calcula un score para determinar la calidad de un time block
  static int _calculateBlockScore(TimeBlockModel block) {
    int score = 0;

    // Puntos por tener descripción
    if (block.description.isNotEmpty) score += 2;

    // Puntos por tener marcador de actividad
    if (block.description.contains('[ACTIVITY_GENERATED]')) score += 5;

    // Puntos por tener categoría
    if (block.category.isNotEmpty) score += 1;

    // Puntos por estar completado (indica uso real)
    if (block.isCompleted) score += 3;

    // Puntos por ser tiempo de enfoque
    if (block.isFocusTime) score += 1;

    return score;
  }

  /// Formatea una fecha para logging
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Muestra estadísticas de duplicados sin eliminarlos
  static Future<Map<String, int>> analyzeDuplicates() async {
    try {
      debugPrint('📊 Analizando duplicados...');

      final stats = <String, int>{
        'totalDates': 0,
        'datesWithDuplicates': 0,
        'totalDuplicates': 0,
      };

      final now = DateTime.now();

      for (int i = -30; i <= 30; i++) {
        final date = now.add(Duration(days: i));
        final timeBlocks = await _timeBlockRepo.getTimeBlocksByDate(date);

        stats['totalDates'] = stats['totalDates']! + 1;

        if (timeBlocks.length > 1) {
          final duplicateGroups = <String, List<TimeBlockModel>>{};

          for (final block in timeBlocks) {
            final key = _generateDuplicateKey(block);
            duplicateGroups.putIfAbsent(key, () => []).add(block);
          }

          int duplicatesForDate = 0;
          for (final blocks in duplicateGroups.values) {
            if (blocks.length > 1) {
              duplicatesForDate += blocks.length - 1; // Contar solo los extras
            }
          }

          if (duplicatesForDate > 0) {
            stats['datesWithDuplicates'] = stats['datesWithDuplicates']! + 1;
            stats['totalDuplicates'] =
                stats['totalDuplicates']! + duplicatesForDate;
            debugPrint(
                '📅 ${_formatDate(date)}: $duplicatesForDate duplicados');
          }
        }
      }

      debugPrint('📊 Estadísticas:');
      debugPrint('   📅 Fechas analizadas: ${stats['totalDates']}');
      debugPrint(
          '   🔍 Fechas con duplicados: ${stats['datesWithDuplicates']}');
      debugPrint(
          '   🗑️ Total duplicados encontrados: ${stats['totalDuplicates']}');

      return stats;
    } catch (e) {
      debugPrint('❌ Error analizando duplicados: $e');
      return {};
    }
  }
}
