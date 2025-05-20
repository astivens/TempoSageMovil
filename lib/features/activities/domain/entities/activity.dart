class Activity {
  final String id;
  final String name;
  final DateTime date;
  final String category;
  final String description;
  final bool isCompleted;

  Activity({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.description,
    required this.isCompleted,
  });
}
