import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String passwordHash;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
  });

  factory UserModel.create({
    required String email,
    required String name,
    required String password,
  }) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      passwordHash: password, // En producción deberías usar un hash real
    );
  }
}
