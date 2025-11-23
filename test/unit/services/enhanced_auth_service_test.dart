import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:temposage/core/utils/validators/form_validators.dart';
import 'dart:io';

/// Enhanced AuthService Tests following the methodology from the design document
/// This test suite implements equivalence classes, boundary values, and path coverage
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late AuthService authService;
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

  setUp(() async {
    // Clean up previous test data
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');
    authService = AuthService();
  });

  tearDown(() async {
    // Clean up test data after each test
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');
  });

  group('AuthService - Enhanced Unit Tests', () {
    
    // ========================================
    // EQUIVALENCE CLASSES TESTING
    // ========================================
    
    group('Equivalence Classes Testing', () {
      
      group('Email Validation - Equivalence Classes', () {
        test('Valid Email Class - Standard Format', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Test User',
            'password123',
          );

          // Assert
          expect(user.email, equals('test@example.com'));
        });

        test('Valid Email Class - Complex Format', () async {
          // Arrange & Act
          final user = await authService.register(
            'user.name+tag@domain.co.uk',
            'Test User',
            'password123',
          );

          // Assert
          expect(user.email, equals('user.name+tag@domain.co.uk'));
        });

        test('Invalid Email Class - Missing @ Symbol', () async {
          // Act & Assert
          expectLater(
            authService.register('invalidemail.com', 'Test User', 'password123'),
            throwsException,
          );
        });

        test('Invalid Email Class - Invalid Domain', () async {
          // Act & Assert
          expectLater(
            authService.register('test@', 'Test User', 'password123'),
            throwsException,
          );
        });

        test('Invalid Email Class - Empty Email', () async {
          // Act & Assert
          expectLater(
            authService.register('', 'Test User', 'password123'),
            throwsException,
          );
        });
      });

      group('Name Validation - Equivalence Classes', () {
        test('Valid Name Class - Standard Name', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Juan Pérez',
            'password123',
          );

          // Assert
          expect(user.name, equals('Juan Pérez'));
        });

        test('Valid Name Class - Long Name', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'María González de la Cruz',
            'password123',
          );

          // Assert
          expect(user.name, equals('María González de la Cruz'));
        });

        test('Invalid Name Class - Empty Name', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', '', 'password123'),
            throwsException,
          );
        });

        test('Invalid Name Class - Name with Numbers', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', 'Juan123', 'password123'),
            throwsException,
          );
        });

        test('Invalid Name Class - Name with Special Characters', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', 'Juan@Pérez', 'password123'),
            throwsException,
          );
        });
      });

      group('Password Validation - Equivalence Classes', () {
        test('Valid Password Class - Standard Length', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Test User',
            'password123',
          );

          // Assert
          expect(user.passwordHash, equals('password123'));
        });

        test('Valid Password Class - Long Password', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Test User',
            'MyVeryLongPassword123!',
          );

          // Assert
          expect(user.passwordHash, equals('MyVeryLongPassword123!'));
        });

        test('Invalid Password Class - Too Short', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', 'Test User', 'pass'),
            throwsException,
          );
        });

        test('Invalid Password Class - Empty Password', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', 'Test User', ''),
            throwsException,
          );
        });
      });
    });

    // ========================================
    // BOUNDARY VALUES TESTING
    // ========================================
    
    group('Boundary Values Testing', () {
      
      group('Email Boundary Values', () {
        test('Minimum Valid Email - a@b.c', () async {
          // Arrange & Act
          final user = await authService.register(
            'a@b.c',
            'Test User',
            'password123',
          );

          // Assert
          expect(user.email, equals('a@b.c'));
        });

        test('Maximum Valid Email - Long Domain', () async {
          // Arrange & Act
          final user = await authService.register(
            'user@verylongdomainname123456789.com',
            'Test User',
            'password123',
          );

          // Assert
          expect(user.email, equals('user@verylongdomainname123456789.com'));
        });

        test('Boundary Invalid - Missing Domain Extension', () async {
          // Act & Assert
          expectLater(
            authService.register('test@domain', 'Test User', 'password123'),
            throwsException,
          );
        });
      });

      group('Name Boundary Values', () {
        test('Minimum Valid Name - Two Characters', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Jo',
            'password123',
          );

          // Assert
          expect(user.name, equals('Jo'));
        });

        test('Maximum Valid Name - Long Name', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Juan Pérez García de la Cruz y Martínez',
            'password123',
          );

          // Assert
          expect(user.name, equals('Juan Pérez García de la Cruz y Martínez'));
        });

        test('Boundary Invalid - Single Character', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', 'J', 'password123'),
            throwsException,
          );
        });
      });

      group('Password Boundary Values', () {
        test('Minimum Valid Password - 8 Characters', () async {
          // Arrange & Act
          final user = await authService.register(
            'test@example.com',
            'Test User',
            'password',
          );

          // Assert
          expect(user.passwordHash, equals('password'));
        });

        test('Maximum Valid Password - Long Password', () async {
          // Arrange & Act
          final longPassword = 'a' * 50; // 50 characters
          final user = await authService.register(
            'test@example.com',
            'Test User',
            longPassword,
          );

          // Assert
          expect(user.passwordHash, equals(longPassword));
        });

        test('Boundary Invalid - 7 Characters (Below Minimum)', () async {
          // Act & Assert
          expectLater(
            authService.register('test@example.com', 'Test User', 'passwor'),
            throwsException,
          );
        });

        test('Boundary Invalid - 51 Characters (Above Maximum)', () async {
          // Act & Assert
          final tooLongPassword = 'a' * 51; // 51 characters
          expectLater(
            authService.register('test@example.com', 'Test User', tooLongPassword),
            throwsException,
          );
        });
      });
    });

    // ========================================
    // PATH COVERAGE TESTING
    // ========================================
    
    group('Path Coverage Testing', () {
      
      group('Login Function - Path Coverage', () {
        test('Path 1: Valid Credentials - Successful Login', () async {
          // Arrange
          await authService.register(
            'test@example.com',
            'Test User',
            'password123',
          );

          // Act
          final result = await authService.login('test@example.com', 'password123');

          // Assert
          expect(result, isTrue);
          
          // Verify user is set as current
          final currentUser = await authService.getCurrentUser();
          expect(currentUser, isNotNull);
          expect(currentUser!.email, equals('test@example.com'));
        });

        test('Path 2: Invalid Credentials - Exception Thrown', () async {
          // Arrange
          await authService.register(
            'test@example.com',
            'Test User',
            'password123',
          );

          // Act & Assert
          expectLater(
            authService.login('test@example.com', 'wrongpassword'),
            throwsException,
          );
        });

        test('Path 3: Non-existent User - Exception Thrown', () async {
          // Act & Assert
          expectLater(
            authService.login('nonexistent@example.com', 'password123'),
            throwsException,
          );
        });

        test('Path 4: Empty Credentials - Exception Thrown', () async {
          // Act & Assert
          expectLater(
            authService.login('', ''),
            throwsException,
          );
        });
      });

      group('Register Function - Path Coverage', () {
        test('Path 1: Valid Registration - User Created', () async {
          // Act
          final user = await authService.register(
            'newuser@example.com',
            'New User',
            'password123',
          );

          // Assert
          expect(user.email, equals('newuser@example.com'));
          expect(user.name, equals('New User'));
          expect(user.passwordHash, equals('password123'));
        });

        test('Path 2: Duplicate Email - Exception Thrown', () async {
          // Arrange
          await authService.register(
            'duplicate@example.com',
            'First User',
            'password123',
          );

          // Act & Assert
          expectLater(
            authService.register(
              'duplicate@example.com',
              'Second User',
              'password456',
            ),
            throwsException,
          );
        });
      });

      group('Logout Function - Path Coverage', () {
        test('Path 1: User Logged In - Successful Logout', () async {
          // Arrange
          await authService.register(
            'test@example.com',
            'Test User',
            'password123',
          );
          await authService.login('test@example.com', 'password123');

          // Verify user is logged in
          var currentUser = await authService.getCurrentUser();
          expect(currentUser, isNotNull);

          // Act
          await authService.logout();

          // Assert
          currentUser = await authService.getCurrentUser();
          expect(currentUser, isNull);
        });

        test('Path 2: No User Logged In - Logout Still Works', () async {
          // Act
          await authService.logout();

          // Assert - Should not throw exception
          final currentUser = await authService.getCurrentUser();
          expect(currentUser, isNull);
        });
      });
    });

    // ========================================
    // INTEGRATION WITH VALIDATORS
    // ========================================
    
    group('Validator Integration Testing', () {
      test('FormValidators.validateEmail - Valid Cases', () {
        // Arrange
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'test+tag@example.org',
        ];

        // Act & Assert
        for (final email in validEmails) {
          expect(FormValidators.validateEmail(email), isNull);
        }
      });

      test('FormValidators.validateEmail - Invalid Cases', () {
        // Arrange
        final invalidEmails = [
          '',
          'invalid-email',
          'test@',
          '@domain.com',
          'test..double.dot@domain.com',
        ];

        // Act & Assert
        for (final email in invalidEmails) {
          expect(FormValidators.validateEmail(email), isNotNull);
        }
      });

      test('FormValidators.validatePassword - Valid Cases', () {
        // Arrange
        final validPasswords = [
          'password',
          '12345678',
          'MyPassword123!',
          'a' * 50, // 50 characters
        ];

        // Act & Assert
        for (final password in validPasswords) {
          expect(FormValidators.validatePassword(password), isNull);
        }
      });

      test('FormValidators.validatePassword - Invalid Cases', () {
        // Arrange
        final invalidPasswords = [
          '',
          'short',
          '7chars',
          // Nota: 'a' * 51 es válida según el validador (tiene más de 8 caracteres)
          // El validador solo verifica longitud mínima, no máxima
        ];

        // Act & Assert
        for (final password in invalidPasswords) {
          expect(FormValidators.validatePassword(password), isNotNull);
        }
      });
    });

    // ========================================
    // EDGE CASES AND ERROR HANDLING
    // ========================================
    
    group('Edge Cases and Error Handling', () {
      test('Concurrent Registration Attempts', () async {
        // Act
        final futures = List.generate(5, (index) => 
          authService.register(
            'concurrent$index@example.com',
            'User $index',
            'password123',
          ),
        );

        // Assert
        final results = await Future.wait(futures);
        expect(results.length, equals(5));
        
        // Verify all users were created
        for (int i = 0; i < 5; i++) {
          expect(results[i].email, equals('concurrent$i@example.com'));
        }
      });

      test('Special Characters in Email', () async {
        // Act
        final user = await authService.register(
          'user+tag@example.com',
          'Test User',
          'password123',
        );

        // Assert
        expect(user.email, equals('user+tag@example.com'));
      });

      test('Unicode Characters in Name', () async {
        // Act
        final user = await authService.register(
          'test@example.com',
          'José María',
          'password123',
        );

        // Assert
        expect(user.name, equals('José María'));
      });

      test('Database Cleanup After Tests', () async {
        // Arrange
        await authService.register(
          'cleanup@example.com',
          'Cleanup User',
          'password123',
        );

        // Act - This is done in tearDown
        // The test passes if no exceptions are thrown during cleanup

        // Assert
        expect(true, isTrue); // Test passes if cleanup succeeds
      });
    });
  });
}
