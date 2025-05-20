import 'package:hive/hive.dart';
import 'activity_model.dart';

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 1; // Asegúrate de que este ID no esté en uso

  @override
  ActivityModel read(BinaryReader reader) {
    return ActivityModel.fromJson(reader.readMap().cast<String, dynamic>());
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer.writeMap(obj.toJson());
  }
}
