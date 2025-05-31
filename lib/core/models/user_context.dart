/// Modelo de datos para el contexto del usuario
class UserContext {
  final int priority; // 1-5
  final double energyLevel; // 0.0-1.0
  final double moodLevel; // 0.0-1.0
  final String predictedCategory;

  const UserContext({
    this.priority = 3,
    this.energyLevel = 0.5,
    this.moodLevel = 0.5,
    this.predictedCategory = '',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserContext &&
        other.priority == priority &&
        other.energyLevel == energyLevel &&
        other.moodLevel == moodLevel &&
        other.predictedCategory == predictedCategory;
  }

  @override
  int get hashCode {
    return priority.hashCode ^
        energyLevel.hashCode ^
        moodLevel.hashCode ^
        predictedCategory.hashCode;
  }
}
