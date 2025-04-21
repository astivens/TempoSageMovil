class Activity {
  final String id;
  final String name;
  final DateTime date;
  final String category;
  final String? description;
  final bool isCompleted;

  const Activity({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    this.description,
    this.isCompleted = false,
  });
}
