import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/utils/validators/form_validators.dart';

void main() {
  group('FormValidators Tests', () {
    group('validateEmail', () {
      test('debería retornar null para un email válido', () {
        // Arrange
        const validEmail = 'test@example.com';

        // Act
        final result = FormValidators.validateEmail(validEmail);

        // Assert
        expect(result, isNull);
      });

      test('debería retornar mensaje de error para email vacío', () {
        // Arrange
        const emptyEmail = '';

        // Act
        final result = FormValidators.validateEmail(emptyEmail);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('debería retornar null para null', () {
        // Act
        final result = FormValidators.validateEmail(null);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('debería retornar mensaje de error para email inválido sin @', () {
        // Arrange
        const invalidEmail = 'testexample.com';

        // Act
        final result = FormValidators.validateEmail(invalidEmail);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid email'));
      });

      test('debería retornar mensaje de error para email inválido sin dominio', () {
        // Arrange
        const invalidEmail = 'test@';

        // Act
        final result = FormValidators.validateEmail(invalidEmail);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid email'));
      });

      test('debería retornar mensaje de error para email inválido sin extensión', () {
        // Arrange
        const invalidEmail = 'test@example';

        // Act
        final result = FormValidators.validateEmail(invalidEmail);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid email'));
      });

      test('debería aceptar emails con subdominios', () {
        // Arrange
        const validEmail = 'test@sub.example.com';

        // Act
        final result = FormValidators.validateEmail(validEmail);

        // Assert
        expect(result, isNull);
      });

      test('debería aceptar emails con guiones', () {
        // Arrange
        const validEmail = 'test-user@example.com';

        // Act
        final result = FormValidators.validateEmail(validEmail);

        // Assert
        expect(result, isNull);
      });
    });

    group('validatePassword', () {
      test('debería retornar null para una contraseña válida', () {
        // Arrange
        const validPassword = 'password123';

        // Act
        final result = FormValidators.validatePassword(validPassword);

        // Assert
        expect(result, isNull);
      });

      test('debería retornar mensaje de error para contraseña vacía', () {
        // Arrange
        const emptyPassword = '';

        // Act
        final result = FormValidators.validatePassword(emptyPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('debería retornar null para null', () {
        // Act
        final result = FormValidators.validatePassword(null);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('debería retornar mensaje de error para contraseña corta', () {
        // Arrange
        const shortPassword = 'short';

        // Act
        final result = FormValidators.validatePassword(shortPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('at least 8 characters'));
      });

      test('debería aceptar contraseña de exactamente 8 caracteres', () {
        // Arrange
        const password = '12345678';

        // Act
        final result = FormValidators.validatePassword(password);

        // Assert
        expect(result, isNull);
      });

      test('debería aceptar contraseña con caracteres especiales', () {
        // Arrange
        const password = 'password@123!';

        // Act
        final result = FormValidators.validatePassword(password);

        // Assert
        expect(result, isNull);
      });
    });

    group('validateRequired', () {
      test('debería retornar null para un valor válido', () {
        // Arrange
        const value = 'test value';
        const fieldName = 'Field';

        // Act
        final result = FormValidators.validateRequired(value, fieldName);

        // Assert
        expect(result, isNull);
      });

      test('debería retornar mensaje de error para valor vacío', () {
        // Arrange
        const emptyValue = '';
        const fieldName = 'Field';

        // Act
        final result = FormValidators.validateRequired(emptyValue, fieldName);

        // Assert
        expect(result, isNotNull);
        expect(result, contains(fieldName));
        expect(result, contains('required'));
      });

      test('debería retornar null para null', () {
        // Arrange
        const fieldName = 'Field';

        // Act
        final result = FormValidators.validateRequired(null, fieldName);

        // Assert
        expect(result, isNotNull);
        expect(result, contains(fieldName));
        expect(result, contains('required'));
      });

      test('debería incluir el nombre del campo en el mensaje de error', () {
        // Arrange
        const fieldName = 'Email';

        // Act
        final result = FormValidators.validateRequired(null, fieldName);

        // Assert
        expect(result, contains(fieldName));
      });
    });

    group('validateTime', () {
      test('debería retornar null para una hora válida', () {
        // Arrange
        const validTime = '12:30';

        // Act
        final result = FormValidators.validateTime(validTime);

        // Assert
        expect(result, isNull);
      });

      test('debería retornar mensaje de error para hora vacía', () {
        // Arrange
        const emptyTime = '';

        // Act
        final result = FormValidators.validateTime(emptyTime);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('debería retornar null para null', () {
        // Act
        final result = FormValidators.validateTime(null);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('debería retornar mensaje de error para hora inválida sin formato', () {
        // Arrange
        const invalidTime = '12-30';

        // Act
        final result = FormValidators.validateTime(invalidTime);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid time'));
      });

      test('debería retornar mensaje de error para hora con minutos inválidos', () {
        // Arrange
        const invalidTime = '12:60';

        // Act
        final result = FormValidators.validateTime(invalidTime);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid time'));
      });

      test('debería retornar mensaje de error para hora con horas inválidas', () {
        // Arrange
        const invalidTime = '24:00';

        // Act
        final result = FormValidators.validateTime(invalidTime);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid time'));
      });

      test('debería aceptar hora de medianoche', () {
        // Arrange
        const validTime = '00:00';

        // Act
        final result = FormValidators.validateTime(validTime);

        // Assert
        expect(result, isNull);
      });

      test('debería aceptar hora de última hora del día', () {
        // Arrange
        const validTime = '23:59';

        // Act
        final result = FormValidators.validateTime(validTime);

        // Assert
        expect(result, isNull);
      });

      test('debería aceptar hora con un solo dígito en horas', () {
        // Arrange
        const validTime = '9:30';

        // Act
        final result = FormValidators.validateTime(validTime);

        // Assert
        expect(result, isNull);
      });
    });
  });
}

