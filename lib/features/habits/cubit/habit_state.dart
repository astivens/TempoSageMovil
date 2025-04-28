part of 'habit_cubit.dart';

@freezed
class HabitState with _$HabitState {
  const factory HabitState.initial() = _Initial;
  const factory HabitState.loading() = _Loading;
  const factory HabitState.loaded({required List<Habit> habits}) = _Loaded;
  const factory HabitState.error({required String errorMessage}) = _Error;
}
