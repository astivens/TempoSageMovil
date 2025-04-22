import 'package:hive_flutter/hive_flutter.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/data/models/time_of_day_adapter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Registrar adaptadores
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());

  // Abrir cajas
  await Hive.openBox<HabitModel>('habits');
}
