import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';

void main() {
  late AuthService authService;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);

    // Registrar adaptadores
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Limpiar datos de pruebas anteriores
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');

    // Inicializar el servicio
    authService = AuthService();
  });

  tearDown(() async {
    // Limpiar todos los datos después de cada prueba
    // Cerrar las cajas antes de eliminarlas
    try {
      final usersBox = Hive.box<UserModel>('users');
      if (usersBox.isOpen) {
        await usersBox.close();
      }
    } catch (e) {
      // La caja puede no estar abierta o ya estar cerrada
    }
    try {
      final authBox = Hive.box('auth');
      if (authBox.isOpen) {
        await authBox.close();
      }
    } catch (e) {
      // La caja puede no estar abierta o ya estar cerrada
    }
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');
  });

  group('AuthService Tests', () {
    test('register crea un nuevo usuario correctamente', () async {
      // Act
      final user = await authService.register(
        'test@example.com',
        'Test User',
        '12345678',
      );

      // Assert
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.passwordHash, '12345678');

      // Verificar que el usuario está guardado en la base de datos
      final box = await Hive.openBox<UserModel>('users');
      final savedUser = box.get(user.id);
      expect(savedUser, isNotNull);
      expect(savedUser!.email, 'test@example.com');
    });

    test('login funciona correctamente con credenciales válidas', () async {
      // Arrange - crear un usuario primero
      await authService.register(
        'test@example.com',
        'Test User',
        '12345678',
      );

      // Act
      final result = await authService.login('test@example.com', '12345678');

      // Assert
      expect(result, true);

      // Verificar que el usuario está marcado como actual
      final currentUser = await authService.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.email, 'test@example.com');
    });

    test('login lanza excepción con credenciales inválidas', () async {
      // Arrange - crear un usuario primero
      await authService.register(
        'test@example.com',
        'Test User',
        '12345678',
      );

      // Act & Assert
      expect(
        () => authService.login('test@example.com', 'wrong_password'),
        throwsException,
      );
    });

    test('logout elimina la sesión actual', () async {
      // Arrange - crear un usuario y hacer login
      await authService.register(
        'test@example.com',
        'Test User',
        '12345678',
      );
      await authService.login('test@example.com', '12345678');

      // Verificar que hay una sesión activa
      var currentUser = await authService.getCurrentUser();
      expect(currentUser, isNotNull);

      // Act
      await authService.logout();

      // Assert
      currentUser = await authService.getCurrentUser();
      expect(currentUser, isNull);
    });

    test('createInitialUser crea un usuario de prueba', () async {
      // Act
      await authService.createInitialUser();

      // Assert
      final box = await Hive.openBox<UserModel>('users');
      expect(box.isNotEmpty, true);

      // Verificar que podemos iniciar sesión con ese usuario
      final result = await authService.login('test@example.com', '12345678');
      expect(result, true);
    });
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });
}
