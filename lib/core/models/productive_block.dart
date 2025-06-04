import 'package:hive/hive.dart';

part 'productive_block.g.dart';

@HiveType(typeId: 7)
class ProductiveBlock {
  @HiveField(0)
  final int weekday; // 0-6 (lunes-domingo)
  @HiveField(1)
  final int hour; // 0-23
  @HiveField(2)
  final double completionRate;
  @HiveField(3)
  final bool isProductiveBlock;
  @HiveField(4)
  final String? category; // Nueva propiedad

  ProductiveBlock({
    required this.weekday,
    required this.hour,
    required this.completionRate,
    this.isProductiveBlock = false,
    this.category,
  });

  factory ProductiveBlock.fromMap(Map<String, dynamic> map) {
    return ProductiveBlock(
      weekday: map['weekday'] ?? 0,
      hour: map['hour'] ?? 0,
      completionRate: map['completion_rate'] ?? 0.0,
      isProductiveBlock: map['is_productive'] ?? false,
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekday': weekday,
      'hour': hour,
      'completion_rate': completionRate,
      'is_productive': isProductiveBlock,
      'category': category,
    };
  }

  @override
  String toString() {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final dayName =
        weekday >= 0 && weekday < days.length ? days[weekday] : 'Desconocido';
    final hourFormatted = hour < 10 ? '0$hour:00' : '$hour:00';
    final percentage = (completionRate * 100).toStringAsFixed(1);
    final categoryStr = category != null ? ' ($category)' : '';

    return '$dayName a las $hourFormatted$categoryStr (Tasa de completado: $percentage%)';
  }

  // Para ordenar bloques por tasa de completado
  static List<ProductiveBlock> sortByCompletionRate(
      List<ProductiveBlock> blocks) {
    final sortedBlocks = List<ProductiveBlock>.from(blocks);
    sortedBlocks.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return sortedBlocks;
  }

  // Filtrar bloques por categoría
  static List<ProductiveBlock> filterByCategory(
      List<ProductiveBlock> blocks, String category) {
    // Si no hay categoría o está vacía, devolver todos los bloques
    if (category.isEmpty) return blocks;

    // Filtrar por bloques que coincidan con la categoría o no tengan categoría
    return blocks
        .where((block) =>
            block.category == null ||
            block.category!.isEmpty ||
            block.category!.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
