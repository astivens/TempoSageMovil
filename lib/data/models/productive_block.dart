class ProductiveBlock {
  final int weekday;
  final int hour;
  final double rate;

  ProductiveBlock({
    required this.weekday,
    required this.hour,
    required this.rate,
  });

  /// Construye un ProductiveBlock a partir de una fila CSV: [weekday, hour, rate]
  factory ProductiveBlock.fromCsv(List<dynamic> row) {
    return ProductiveBlock(
      weekday: int.parse(row[0].toString()),
      hour: int.parse(row[1].toString()),
      rate: double.parse(row[2].toString()),
    );
  }
}
