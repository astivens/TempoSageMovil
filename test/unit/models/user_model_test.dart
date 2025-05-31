import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/models/user_model.dart';
import 'package:temposage/core/exceptions/model_exception.dart';

void main() {
  group('UserModel Tests', () {
    final DateTime now = DateTime.now();
    final String validEmail = 'test@example.com';
    final String validName = 'Test User';
    final String validId = 'user-123';

    test('should create a valid UserModel', () {
      // Arrange & Act
      final user = UserModel(
        id: validId,
        email: validEmail,
        name: validName,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(user.id, equals(validId));
      expect(user.email, equals(validEmail));
      expect(user.name, equals(validName));
      expect(user.createdAt, equals(now));
      expect(user.updatedAt, equals(now));
    });

    test('should create UserModel from JSON', () {
      // Arrange
      final json = {
        'id': validId,
        'email': validEmail,
        'name': validName,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.id, equals(validId));
      expect(user.email, equals(validEmail));
      expect(user.name, equals(validName));
      expect(user.createdAt.toIso8601String(), equals(now.toIso8601String()));
      expect(user.updatedAt.toIso8601String(), equals(now.toIso8601String()));
    });

    test('should convert UserModel to JSON', () {
      // Arrange
      final user = UserModel(
        id: validId,
        email: validEmail,
        name: validName,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], equals(validId));
      expect(json['email'], equals(validEmail));
      expect(json['name'], equals(validName));
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['updatedAt'], equals(now.toIso8601String()));
    });

    test('should throw ModelException for invalid email', () {
      // Arrange & Act & Assert
      expect(
        () => UserModel(
          id: validId,
          email: 'invalid-email',
          name: validName,
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<ModelException>()),
      );
    });

    test('should throw ArgumentError for empty name', () {
      // Arrange & Act & Assert
      expect(
        () => UserModel(
          id: validId,
          email: validEmail,
          name: '',
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError for whitespace-only name', () {
      // Arrange & Act & Assert
      expect(
        () => UserModel(
          id: validId,
          email: validEmail,
          name: '   ',
          createdAt: now,
          updatedAt: now,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should create copy with modified values', () {
      // Arrange
      final originalUser = UserModel(
        id: validId,
        email: validEmail,
        name: validName,
        createdAt: now,
        updatedAt: now,
      );

      final newName = 'New Name';
      final newEmail = 'new@example.com';

      // Act
      final modifiedUser = originalUser.copyWith(
        name: newName,
        email: newEmail,
      );

      // Assert
      expect(modifiedUser.id, equals(originalUser.id));
      expect(modifiedUser.name, equals(newName));
      expect(modifiedUser.email, equals(newEmail));
      expect(modifiedUser.createdAt, equals(originalUser.createdAt));
      expect(modifiedUser.updatedAt, equals(originalUser.updatedAt));
    });

    test('should maintain equality with same values', () {
      // Arrange
      final user1 = UserModel(
        id: validId,
        email: validEmail,
        name: validName,
        createdAt: now,
        updatedAt: now,
      );

      final user2 = UserModel(
        id: validId,
        email: validEmail,
        name: validName,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should have different hash codes for different users', () {
      // Arrange
      final user1 = UserModel(
        id: 'user-1',
        email: 'user1@example.com',
        name: 'User 1',
        createdAt: now,
        updatedAt: now,
      );

      final user2 = UserModel(
        id: 'user-2',
        email: 'user2@example.com',
        name: 'User 2',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(user1.hashCode, isNot(equals(user2.hashCode)));
    });
  });
}
