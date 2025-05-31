import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';

void main() {
  late AuthService authService;
  late Box<UserModel> usersBox;
  late Box<String> authBox;
  late Directory tempDir;

  setUpAll(() async {
    // Inicializar Flutter binding
    TestWidgetsFlutterBinding.ensureInitialized();

    // Crear directorio temporal para las pruebas
    tempDir = await Directory.systemTemp.createTemp('temposage_test_');

    // Inicializar Hive para pruebas
    await Hive.initFlutter(tempDir.path);
    Hive.registerAdapter(UserModelAdapter());
  });

  setUp(() async {
    // Limpiar las cajas antes de cada prueba
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');

    // Inicializar el servicio
    authService = AuthService();
    usersBox = await Hive.openBox<UserModel>('users');
    authBox = await Hive.openBox<String>('auth');
  });

  tearDown(() async {
    // Cerrar las cajas después de cada prueba
    await usersBox.close();
    await authBox.close();
  });

  tearDownAll(() async {
    // Limpiar el directorio temporal
    await tempDir.delete(recursive: true);
  });

  group('Flujo de Autenticación', () {
    test('Registro exitoso de usuario', () async {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const password = '12345678';

      // Act
      final user = await authService.register(email, name, password);

      // Assert
      expect(user.email, equals(email));
      expect(user.name, equals(name));
      expect(user.passwordHash, equals(password));
      expect(usersBox.get(user.id), isNotNull);
    });

    test('Registro fallido con email duplicado', () async {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const password = '12345678';

      // Act & Assert
      await authService.register(email, name, password);
      expect(
        () => authService.register(email, name, password),
        throwsException,
      );
    });

    test('Login exitoso', () async {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const password = '12345678';
      final user = await authService.register(email, name, password);

      // Act
      final success = await authService.login(email, password);
      final currentUser = await authService.getCurrentUser();

      // Assert
      expect(success, isTrue);
      expect(currentUser, isNotNull);
      expect(currentUser?.id, equals(user.id));
    });

    test('Login fallido con credenciales incorrectas', () async {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const password = '12345678';
      await authService.register(email, name, password);

      // Act & Assert
      expect(
        () => authService.login(email, 'wrong_password'),
        throwsException,
      );
    });

    test('Logout exitoso', () async {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const password = '12345678';
      await authService.register(email, name, password);
      await authService.login(email, password);

      // Act
      await authService.logout();
      final currentUser = await authService.getCurrentUser();

      // Assert
      expect(currentUser, isNull);
    });

    test('Flujo completo de registro, login y logout', () async {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const password = '12345678';

      // Act & Assert - Registro
      final user = await authService.register(email, name, password);
      expect(user.email, equals(email));

      // Act & Assert - Login
      final loginSuccess = await authService.login(email, password);
      expect(loginSuccess, isTrue);

      var currentUser = await authService.getCurrentUser();
      expect(currentUser?.id, equals(user.id));

      // Act & Assert - Logout
      await authService.logout();
      currentUser = await authService.getCurrentUser();
      expect(currentUser, isNull);
    });

    // Nuevas pruebas de integración
    group('Validación de datos', () {
      test('Registro fallido con email inválido', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const name = 'Test User';
        const password = '12345678';

        // Act & Assert
        expect(
          () => authService.register(invalidEmail, name, password),
          throwsException,
        );
      });

      test('Registro fallido con contraseña corta', () async {
        // Arrange
        const email = 'test@example.com';
        const name = 'Test User';
        const shortPassword = '123';

        // Act & Assert
        expect(
          () => authService.register(email, name, shortPassword),
          throwsException,
        );
      });

      test('Registro fallido con nombre vacío', () async {
        // Arrange
        const email = 'test@example.com';
        const emptyName = '';
        const password = '12345678';

        // Act & Assert
        expect(
          () => authService.register(email, emptyName, password),
          throwsException,
        );
      });
    });

    group('Persistencia de sesión', () {
      test('La sesión persiste después de reiniciar el servicio', () async {
        // Arrange
        const email = 'test@example.com';
        const name = 'Test User';
        const password = '12345678';
        await authService.register(email, name, password);
        await authService.login(email, password);

        // Act
        // Crear una nueva instancia del servicio
        final newAuthService = AuthService();
        final currentUser = await newAuthService.getCurrentUser();

        // Assert
        expect(currentUser, isNotNull);
        expect(currentUser?.email, equals(email));
      });

      test('Múltiples sesiones no interfieren entre sí', () async {
        // Arrange
        const email1 = 'user1@example.com';
        const email2 = 'user2@example.com';
        const name = 'Test User';
        const password = '12345678';

        // Act
        await authService.register(email1, name, password);
        await authService.register(email2, name, password);
        await authService.login(email1, password);

        // Crear una nueva instancia del servicio
        final newAuthService = AuthService();
        await newAuthService.login(email2, password);

        // Assert
        final currentUser1 = await authService.getCurrentUser();
        final currentUser2 = await newAuthService.getCurrentUser();

        expect(currentUser1?.email, equals(email1));
        expect(currentUser2?.email, equals(email2));
      });
    });

    group('Casos límite', () {
      test('Login con email no registrado', () async {
        // Arrange
        const nonExistentEmail = 'nonexistent@example.com';
        const password = '12345678';

        // Act & Assert
        expect(
          () => authService.login(nonExistentEmail, password),
          throwsException,
        );
      });

      test('Logout sin sesión activa', () async {
        // Act & Assert
        expect(
          () => authService.logout(),
          throwsException,
        );
      });

      test('Registro con caracteres especiales en el nombre', () async {
        // Arrange
        const email = 'test@example.com';
        const name = 'Test User!@#\$%^&*()';
        const password = '12345678';

        // Act
        final user = await authService.register(email, name, password);

        // Assert
        expect(user.name, equals(name));
      });
    });
  });
}
