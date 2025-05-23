import 'package:hive/hive.dart';
import 'activity_model.dart';

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId =
      2; // Cambiado a 2 para evitar colisión con UserModelAdapter (1)

  @override
  ActivityModel read(BinaryReader reader) {
    return ActivityModel.fromJson(reader.readMap().cast<String, dynamic>());
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer.writeMap(obj.toJson());
  }
}
