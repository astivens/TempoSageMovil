import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../data/models/productive_block.dart';

class CSVService {
  /// Carga los Top 3 bloques productivos desde el CSV.
  Future<List<ProductiveBlock>> loadTop3Blocks() async {
    final rawCsv = await rootBundle.loadString(
      'assets/ml_models/top3_productive_blocks.csv',
    );
    final rows = const CsvToListConverter().convert(rawCsv);
    if (rows.isNotEmpty &&
        rows[0].any((e) => e.toString().contains('start_weekday'))) {
      rows.removeAt(0);
    }
    return rows.map((r) => ProductiveBlock.fromCsv(r)).toList();
  }

  /// Carga todos los bloques productivos (stats completos) desde el CSV.
  Future<List<ProductiveBlock>> loadAllBlocks() async {
    final rawCsv = await rootBundle.loadString(
      'assets/ml_models/productive_blocks_stats.csv',
    );
    final rows = const CsvToListConverter().convert(rawCsv);
    if (rows.isNotEmpty &&
        rows[0].any((e) => e.toString().contains('start_weekday'))) {
      rows.removeAt(0);
    }
    return rows.map((r) => ProductiveBlock.fromCsv(r)).toList();
  }
}
