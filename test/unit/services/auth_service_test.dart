import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('AuthService', () {
    late AuthService service;

    setUp(() {
      service = AuthService();
    });

    test('should create initial user without throwing', () async {
      await service.createInitialUser();
      expect(true, isTrue);
    });

    test('should register, login, get current user and logout', () async {
      final user =
          await service.register('test2@example.com', 'Test2', 'pass123');
      expect(user, isA<UserModel>());
      final loginResult = await service.login('test2@example.com', 'pass123');
      expect(loginResult, true);
      final currentUser = await service.getCurrentUser();
      expect(currentUser, isA<UserModel>());
      await service.logout();
      final afterLogout = await service.getCurrentUser();
      expect(afterLogout, isNull);
    });
  });
}
