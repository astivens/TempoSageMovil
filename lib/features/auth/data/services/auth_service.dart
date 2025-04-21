import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user';

  Future<Box<UserModel>> get _box async {
    return await Hive.openBox<UserModel>(_boxName);
  }

  Future<UserModel?> getCurrentUser() async {
    final box = await Hive.openBox<String>('auth');
    final userId = box.get(_currentUserKey);
    if (userId == null) return null;

    final usersBox = await _box;
    return usersBox.get(userId);
  }

  Future<bool> login(String email, String password) async {
    final usersBox = await _box;
    final user = usersBox.values.firstWhere(
      (user) => user.email == email && user.passwordHash == password,
      orElse: () => throw Exception('Invalid credentials'),
    );

    final authBox = await Hive.openBox<String>('auth');
    await authBox.put(_currentUserKey, user.id);
    return true;
  }

  Future<UserModel> register(String email, String name, String password) async {
    final usersBox = await _box;

    // Verificar si el email ya existe
    final exists = usersBox.values.any((user) => user.email == email);
    if (exists) {
      throw Exception('Email already registered');
    }

    final user = UserModel.create(
      email: email,
      name: name,
      password: password,
    );

    await usersBox.put(user.id, user);
    return user;
  }

  Future<void> logout() async {
    final box = await Hive.openBox<String>('auth');
    await box.delete(_currentUserKey);
  }

  // Método de utilidad para desarrollo
  Future<void> createInitialUser() async {
    final usersBox = await _box;
    if (usersBox.isEmpty) {
      final user = UserModel.create(
        email: 'test@example.com',
        name: 'Test User',
        password: '12345678',
      );
      await usersBox.put(user.id, user);
    }
  }
}
