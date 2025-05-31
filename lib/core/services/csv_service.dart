import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/core/utils/logger.dart';

class CSVService {
  static const String _top3BlocksPath =
      'assets/ml_models/TPS_Model/top3_productive_blocks.csv';
  static const String _allBlocksStatsPath =
      'assets/ml_models/TPS_Model/productive_blocks_stats.csv';
  static const String _tasksDatasetPath =
      'assets/ml_models/TPS_Model/tempo_sage_tasks_dataset.csv';

  final Logger _logger = Logger('CSVService');
  final String? customDirectoryPath;

  CSVService({this.customDirectoryPath});

  /// Carga los 3 bloques más productivos desde el CSV
  Future<List<ProductiveBlock>> loadTop3Blocks() async {
    try {
      final String csvContent = await rootBundle.loadString(_top3BlocksPath);
      _logger.i('CSV de top 3 bloques cargado correctamente');
      return _parseProductiveBlocks(csvContent);
    } catch (e) {
      _logger.e('Error al cargar Top 3 bloques productivos: $e');
      // Devolver datos por defecto en caso de error
      return _getDefaultBlocks(3);
    }
  }

  /// Carga todos los bloques con estadísticas de productividad
  Future<List<ProductiveBlock>> loadAllBlocksStats() async {
    try {
      final String csvContent =
          await rootBundle.loadString(_allBlocksStatsPath);
      _logger.i('CSV de estadísticas de bloques cargado correctamente');
      return _parseProductiveBlocks(csvContent);
    } catch (e) {
      _logger.e('Error al cargar estadísticas de bloques productivos: $e');
      // Devolver datos por defecto en caso de error
      return _getDefaultBlocks(5);
    }
  }

  /// Carga estadísticas de bloques productivos por categoría
  Future<Map<String, List<ProductiveBlock>>> loadBlocksByCategory() async {
    try {
      // Cargar el dataset completo de tareas para analizar por categoría
      final String csvContent = await rootBundle.loadString(_tasksDatasetPath);
      final List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvContent);

      // La estructura esperada del CSV incluye: task_id, user_id, description, category, priority...
      final Map<String, List<ProductiveBlock>> blocksByCategory = {};
      final Map<String, Map<String, double>> categoryStats = {};

      // Saltear cabecera
      bool firstRow = true;
      int categoryIndex = -1;
      int weekdayIndex = -1;
      int hourIndex = -1;
      int completedIndex = -1;

      for (var row in csvTable) {
        if (firstRow) {
          // Encontrar índices de las columnas relevantes
          for (int i = 0; i < row.length; i++) {
            final columnName = row[i].toString().toLowerCase();
            if (columnName.contains('category'))
              categoryIndex = i;
            else if (columnName.contains('weekday'))
              weekdayIndex = i;
            else if (columnName.contains('hour'))
              hourIndex = i;
            else if (columnName.contains('completed')) completedIndex = i;
          }

          firstRow = false;

          // Verificar que tenemos todas las columnas necesarias
          if (categoryIndex < 0 ||
              weekdayIndex < 0 ||
              hourIndex < 0 ||
              completedIndex < 0) {
            _logger.e('Formato de CSV inválido: faltan columnas necesarias');
            return {};
          }

          continue;
        }

        // Procesar cada fila para extraer estadísticas
        try {
          final category = row[categoryIndex].toString();
          final weekday = int.tryParse(row[weekdayIndex].toString()) ?? 0;
          final hour = int.tryParse(row[hourIndex].toString()) ?? 0;
          final completed =
              row[completedIndex].toString().toLowerCase() == 'true' ||
                  row[completedIndex].toString() == '1';

          // Clave única para el bloque de tiempo
          final blockKey = '$weekday:$hour';

          // Inicializar la categoría si no existe
          if (!categoryStats.containsKey(category)) {
            categoryStats[category] = {};
          }

          // Inicializar el bloque de tiempo para esta categoría si no existe
          if (!categoryStats[category]!.containsKey(blockKey)) {
            categoryStats[category]![blockKey] = 0.0;
          }

          // Contabilizar tarea completada
          if (completed) {
            categoryStats[category]![blockKey] =
                (categoryStats[category]![blockKey]! + 1.0);
          }
        } catch (e) {
          _logger.w('Error al procesar fila del CSV: $e');
          continue;
        }
      }

      // Convertir las estadísticas recopiladas en bloques productivos
      for (final category in categoryStats.keys) {
        final blocks = <ProductiveBlock>[];

        for (final blockKey in categoryStats[category]!.keys) {
          final parts = blockKey.split(':');
          if (parts.length == 2) {
            final weekday = int.tryParse(parts[0]) ?? 0;
            final hour = int.tryParse(parts[1]) ?? 0;
            final completionRate = categoryStats[category]![blockKey]! /
                10.0; // Normalizar entre 0-1

            blocks.add(ProductiveBlock(
              weekday: weekday,
              hour: hour,
              completionRate: completionRate > 1.0 ? 1.0 : completionRate,
              isProductiveBlock: completionRate > 0.7,
              category: category,
            ));
          }
        }

        // Ordenar bloques por tasa de completado
        blocksByCategory[category] =
            ProductiveBlock.sortByCompletionRate(blocks);
      }

      _logger.i(
          'Bloques productivos por categoría cargados: ${blocksByCategory.length} categorías');
      return blocksByCategory;
    } catch (e) {
      _logger.e('Error al cargar bloques por categoría: $e');
      return {};
    }
  }

  /// Parsea el contenido CSV a una lista de ProductiveBlock
  List<ProductiveBlock> _parseProductiveBlocks(String csvContent) {
    final List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(csvContent);

    // Omitir cabecera si existe
    final startIndex = csvTable.first.length >= 3 &&
            (csvTable.first[0] is String &&
                csvTable.first[0].toString().contains('weekday'))
        ? 1
        : 0;

    final blocks = <ProductiveBlock>[];

    for (int i = startIndex; i < csvTable.length; i++) {
      final row = csvTable[i];
      if (row.length >= 3) {
        final weekday = int.tryParse(row[0].toString()) ?? 0;
        final hour = int.tryParse(row[1].toString()) ?? 0;
        final completionRate = double.tryParse(row[2].toString()) ?? 0.0;

        // Verificar si hay una columna de categoría
        String? category;
        if (row.length >= 4 && row[3] != null) {
          category = row[3].toString();
        }

        blocks.add(ProductiveBlock(
          weekday: weekday,
          hour: hour,
          completionRate: completionRate,
          isProductiveBlock: completionRate > 0.7,
          category: category,
        ));
      }
    }

    return blocks;
  }

  /// Genera bloques productivos por defecto para emergencias
  List<ProductiveBlock> _getDefaultBlocks(int count) {
    final blocks = <ProductiveBlock>[];

    // Añadir algunos bloques por defecto para las pruebas
    blocks.add(ProductiveBlock(
      weekday: 1, // Lunes
      hour: 9, // 9 AM
      completionRate: 0.9,
      isProductiveBlock: true,
      category: "Trabajo",
    ));

    blocks.add(ProductiveBlock(
      weekday: 3, // Miércoles
      hour: 16, // 4 PM
      completionRate: 0.85,
      isProductiveBlock: true,
      category: "Estudio",
    ));

    blocks.add(ProductiveBlock(
      weekday: 5, // Viernes
      hour: 10, // 10 AM
      completionRate: 0.8,
      isProductiveBlock: true,
      category: "Personal",
    ));

    blocks.add(ProductiveBlock(
      weekday: 0, // Domingo
      hour: 20, // 8 PM
      completionRate: 0.75,
      isProductiveBlock: true,
      category: "Ocio",
    ));

    blocks.add(ProductiveBlock(
      weekday: 2, // Martes
      hour: 15, // 3 PM
      completionRate: 0.7,
      isProductiveBlock: true,
      category: "Salud",
    ));

    return blocks.take(count).toList();
  }

  /// Guarda los bloques productivos en un archivo CSV (para posible uso futuro)
  Future<void> saveProductiveBlocks(
      List<ProductiveBlock> blocks, String filename) async {
    String dirPath;
    if (customDirectoryPath != null) {
      dirPath = customDirectoryPath!;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      dirPath = dir.path;
    }
    final file = File('${dirPath}/$filename');

    final List<List<dynamic>> rows = [
      [
        'start_weekday',
        'start_hour',
        'completion_rate',
        'category'
      ], // Cabecera
      ...blocks.map((block) => [
            block.weekday,
            block.hour,
            block.completionRate,
            block.category ?? ''
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    _logger.i('Bloques productivos guardados en: $filename');
  }
}
