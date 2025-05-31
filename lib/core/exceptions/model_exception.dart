class ModelException implements Exception {
  final String message;

  ModelException(this.message);

  @override
  String toString() => 'ModelException: $message';
}
