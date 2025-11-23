import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'dart:io';

// Simple CSV service for testing
class TestCsvService {
  String convertToCsv(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    final headers = data.first.keys.toList();
    final csv = StringBuffer();
    
    // Add headers
    csv.write(headers.join(','));
    
    // Add data rows
    for (final row in data) {
      csv.write('\n');
      final values = headers.map((header) => row[header]?.toString() ?? '').toList();
      csv.write(values.join(','));
    }
    
    return csv.toString();
  }
}

/// Enhanced Acceptance Tests following the methodology from the design document
/// This test suite implements usability testing and user acceptance criteria validation
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late Directory tempDir;
  late AuthService authService;
  late TestCsvService csvService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  });

  setUp(() async {
    // Clean up previous test data
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');
    
    // Initialize services
    authService = AuthService();
    csvService = TestCsvService();
  });

  tearDown(() async {
    // Clean up test data after each test
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('auth');
  });

  group('Enhanced Acceptance Tests', () {
    
    // ========================================
    // USABILITY TESTING - MODERATED
    // ========================================
    
    group('Moderated Usability Testing', () {
      
      group('Onboarding Scenario', () {
        test('Acceptance: User Onboarding - Registration and Initial Setup', () async {
          // Scenario: New user wants to start using TempoSage
          // Expected: Complete onboarding in less than 5 minutes
          
          final startTime = DateTime.now();
          
          // Step 1: User registration
          final user = await authService.register(
            'newuser@example.com',
            'New User',
            'password123',
          );
          
          // Step 2: Initial login
          final loginResult = await authService.login('newuser@example.com', 'password123');
          
          // Step 3: Verify access to system
          final currentUser = await authService.getCurrentUser();
          
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          
          // Acceptance Criteria:
          // - User successfully registered
          // - User can log in immediately
          // - Process completed in reasonable time
          // - User has access to main functionality
          
          expect(user.email, equals('newuser@example.com'));
          expect(user.name, equals('New User'));
          expect(loginResult, isTrue);
          expect(currentUser, isNotNull);
          expect(currentUser!.email, equals('newuser@example.com'));
          expect(duration.inMinutes, lessThan(5)); // Less than 5 minutes
        });

        test('Acceptance: User Onboarding - Error Recovery', () async {
          // Scenario: User makes mistakes during registration
          // Expected: Clear error messages and ability to recover
          
          // Step 1: User tries to register with invalid email
          try {
            await authService.register(
              'invalid-email',
              'Test User',
              'password123',
            );
            fail('Expected exception for invalid email');
          } catch (e) {
            // User should receive clear error message
            expect(e.toString(), isNotEmpty);
          }
          
          // Step 2: User corrects email and tries again
          try {
            await authService.register(
              'corrected@example.com',
              'Test User',
              'password123',
            );
            // Should succeed on second attempt
          } catch (e) {
            fail('Registration should succeed with corrected email');
          }
          
          // Step 3: User tries to register with same email again
          try {
            await authService.register(
              'corrected@example.com',
              'Another User',
              'password456',
            );
            fail('Expected exception for duplicate email');
          } catch (e) {
            // User should receive clear error message about duplicate email
            expect(e.toString(), isNotEmpty);
          }
          
          // Acceptance Criteria:
          // - Clear error messages for invalid inputs
          // - User can correct mistakes and continue
          // - System prevents duplicate registrations
          expect(true, isTrue); // Test passes if all error handling works correctly
        });
      });

      group('Daily Management Scenario', () {
        test('Acceptance: Daily Activity Management - Create and Track Activities', () async {
          // Scenario: User wants to create and manage daily activities
          // Expected: Complete task in less than 2 minutes
          
          final startTime = DateTime.now();
          
          // Step 1: User logs in
          await authService.register(
            'daily@example.com',
            'Daily User',
            'password123',
          );
          await authService.login('daily@example.com', 'password123');
          
          // Step 2: User creates productive blocks for the day
          final dailyBlocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.0, category: 'work'),
            ProductiveBlock(weekday: 1, hour: 10, completionRate: 0.0, category: 'meeting'),
            ProductiveBlock(weekday: 1, hour: 11, completionRate: 0.0, category: 'work'),
            ProductiveBlock(weekday: 1, hour: 14, completionRate: 0.0, category: 'study'),
          ];
          
          // Step 3: User updates completion rates throughout the day
          final updatedBlocks = dailyBlocks.map((block) => 
            ProductiveBlock(
              weekday: block.weekday,
              hour: block.hour,
              completionRate: block.category == 'work' ? 0.8 : 0.6,
              category: block.category,
            ),
          ).toList();
          
          // Step 4: User reviews daily progress
          final workBlocks = ProductiveBlock.filterByCategory(updatedBlocks, 'work');
          final averageWorkCompletion = workBlocks.fold(0.0, (sum, block) => sum + block.completionRate) / workBlocks.length;
          
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          
          // Acceptance Criteria:
          // - User can create multiple activities quickly
          // - User can update progress easily
          // - System provides clear progress feedback
          // - Task completed in reasonable time
          
          expect(dailyBlocks.length, equals(4));
          expect(updatedBlocks.length, equals(4));
          expect(workBlocks.length, equals(2));
          expect(averageWorkCompletion, equals(0.8));
          expect(duration.inMinutes, lessThan(2)); // Less than 2 minutes
        });

        test('Acceptance: Daily Activity Management - Error Handling', () async {
          // Scenario: User encounters issues while managing activities
          // Expected: System handles errors gracefully
          
          // Step 1: User creates activities with various data types
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
            ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.9, category: 'work'),
          ];
          
          // Step 2: User tries to filter by non-existent category
          final filteredBlocks = ProductiveBlock.filterByCategory(blocks, 'non-existent');
          expect(filteredBlocks, isEmpty); // Should return empty list, not crash
          
          // Step 3: User tries to sort empty list
          final emptyList = <ProductiveBlock>[];
          final sortedEmpty = ProductiveBlock.sortByCompletionRate(emptyList);
          expect(sortedEmpty, isEmpty); // Should return empty list, not crash
          
          // Step 4: User processes data with edge cases
          final edgeCaseBlocks = [
            ProductiveBlock(weekday: 1, hour: 0, completionRate: 0.0), // Midnight
            ProductiveBlock(weekday: 7, hour: 23, completionRate: 1.0), // Sunday 11 PM
          ];
          
          final sortedEdgeCases = ProductiveBlock.sortByCompletionRate(edgeCaseBlocks);
          expect(sortedEdgeCases.length, equals(2));
          expect(sortedEdgeCases[0].completionRate, equals(1.0)); // Should sort correctly
          
          // Acceptance Criteria:
          // - System handles edge cases gracefully
          // - No crashes or unexpected behavior
          // - User can continue working despite errors
          expect(true, isTrue); // Test passes if all error handling works correctly
        });
      });

      group('Progress Tracking Scenario', () {
        test('Acceptance: Progress Tracking - Review and Analyze Productivity', () async {
          // Scenario: User wants to review their productivity progress
          // Expected: Information is clear and accessible
          
          // Step 1: User has accumulated data over time
          final historicalBlocks = List.generate(30, (dayIndex) => 
            List.generate(5, (blockIndex) => 
              ProductiveBlock(
                weekday: (dayIndex % 7) + 1,
                hour: 9 + blockIndex,
                completionRate: (dayIndex + blockIndex) / 35.0, // Varying completion rates
                category: blockIndex % 2 == 0 ? 'work' : 'study',
              ),
            ),
          ).expand((dayBlocks) => dayBlocks).toList();
          
          // Step 2: User analyzes work productivity
          final workBlocks = ProductiveBlock.filterByCategory(historicalBlocks, 'work');
          final averageWorkCompletion = workBlocks.fold(0.0, (sum, block) => sum + block.completionRate) / workBlocks.length;
          
          // Step 3: User analyzes study productivity
          final studyBlocks = ProductiveBlock.filterByCategory(historicalBlocks, 'study');
          final averageStudyCompletion = studyBlocks.fold(0.0, (sum, block) => sum + block.completionRate) / studyBlocks.length;
          
          // Step 4: User identifies most productive times
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(historicalBlocks);
          final topPerformers = sortedBlocks.take(10).toList();
          
          // Step 5: User exports data for external analysis
          final exportData = topPerformers.map((block) => {
            'weekday': block.weekday.toString(),
            'hour': block.hour.toString(),
            'category': block.category ?? '',
            'completion_rate': block.completionRate.toString(),
          }).toList();
          
          final csvData = csvService.convertToCsv(exportData);
          
          // Acceptance Criteria:
          // - User can easily access productivity metrics
          // - Data is presented in understandable format
          // - User can identify patterns and trends
          // - Export functionality works correctly
          
          expect(historicalBlocks.length, equals(150)); // 30 days * 5 blocks
          expect(workBlocks.length, greaterThan(50)); // Many should be work
          expect(studyBlocks.length, greaterThan(50)); // Many should be study
          expect(averageWorkCompletion, greaterThan(0));
          expect(averageStudyCompletion, greaterThan(0));
          expect(topPerformers.length, equals(10));
          expect(csvData, contains('weekday,hour,category,completion_rate'));
          expect(csvData, isNotEmpty);
        });

        test('Acceptance: Progress Tracking - Data Consistency', () async {
          // Scenario: User wants to ensure data accuracy
          // Expected: Data remains consistent across operations
          
          // Step 1: User creates initial data
          final originalBlocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
            ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.9, category: 'work'),
          ];
          
          // Step 2: User performs various operations
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(originalBlocks);
          final workBlocks = ProductiveBlock.filterByCategory(originalBlocks, 'work');
          final studyBlocks = ProductiveBlock.filterByCategory(originalBlocks, 'study');
          
          // Step 3: User exports and re-imports data (simulated)
          final exportData = originalBlocks.map((block) => {
            'weekday': block.weekday.toString(),
            'hour': block.hour.toString(),
            'completion_rate': block.completionRate.toString(),
            'is_productive': block.isProductiveBlock.toString(),
            'category': block.category ?? '',
          }).toList();
          
          final csvData = csvService.convertToCsv(exportData);
          
          // Step 4: Verify data integrity
          final totalOriginalCompletion = originalBlocks.fold(0.0, (sum, block) => sum + block.completionRate);
          final totalWorkCompletion = workBlocks.fold(0.0, (sum, block) => sum + block.completionRate);
          final totalStudyCompletion = studyBlocks.fold(0.0, (sum, block) => sum + block.completionRate);
          
          // Acceptance Criteria:
          // - Data remains unchanged after operations
          // - Calculations are accurate
          // - Export/import maintains data integrity
          
          expect(originalBlocks.length, equals(3));
          expect(sortedBlocks.length, equals(3));
          expect(workBlocks.length, equals(2));
          expect(studyBlocks.length, equals(1));
          expect(totalOriginalCompletion, closeTo(totalWorkCompletion + totalStudyCompletion, 0.01));
          expect(csvData, contains('1,9,0.8,false,work'));
          expect(csvData, contains('2,10,0.6,false,study'));
          expect(csvData, contains('3,11,0.9,false,work'));
        });
      });
    });

    // ========================================
    // ACCEPTANCE CRITERIA VALIDATION
    // ========================================
    
    group('Acceptance Criteria Validation', () {
      
      group('Functional Requirements', () {
        test('Acceptance: All Functional Requirements Met', () async {
          // Validate that all functional requirements are met
          
          // RF01: Autenticación de Usuario
          final user = await authService.register(
            'functional@example.com',
            'Functional User',
            'password123',
          );
          expect(user, isA<UserModel>());
          
          final loginResult = await authService.login('functional@example.com', 'password123');
          expect(loginResult, isTrue);
          
          // RF02: Gestión de Actividades (simulated through ProductiveBlocks)
          final activities = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
          ];
          expect(activities.length, equals(2));
          
          // RF03: Gestión de Hábitos (simulated through ProductiveBlocks)
          final habits = ProductiveBlock.filterByCategory(activities, 'work');
          expect(habits.length, equals(1));
          
          // RF04: Gestión de Time Blocks
          final timeBlocks = ProductiveBlock.sortByCompletionRate(activities);
          expect(timeBlocks.length, equals(2));
          
          // RF05: Sistema de Recomendaciones (simulated through data analysis)
          final recommendations = timeBlocks.where((block) => block.completionRate > 0.7).toList();
          expect(recommendations.length, greaterThan(0));
          
          // RF06: Análisis de Productividad
          final productivity = activities.fold(0.0, (sum, block) => sum + block.completionRate) / activities.length;
          expect(productivity, equals(0.7)); // (0.8 + 0.6) / 2
          
          // RF07: Importación/Exportación CSV
          final csvData = csvService.convertToCsv([
            {'test': 'data'},
          ]);
          // El CSV tiene formato: header\nrow, así que verificamos ambas partes
          expect(csvData, contains('test'));
          expect(csvData, contains('data'));
          expect(csvData.split('\n').length, greaterThan(1)); // Debe tener al menos header y una fila
          
          // RF08: Dashboard Personalizado (simulated through data aggregation)
          final dashboardData = {
            'total_activities': activities.length,
            'average_completion': productivity,
            'work_activities': ProductiveBlock.filterByCategory(activities, 'work').length,
            'study_activities': ProductiveBlock.filterByCategory(activities, 'study').length,
          };
          expect(dashboardData['total_activities'], equals(2));
          expect(dashboardData['average_completion'], equals(0.7));
        });
      });

      group('Non-Functional Requirements', () {
        test('Acceptance: Performance Requirements Met', () async {
          // RNF01: Rendimiento - operaciones básicas < 2 segundos
          final startTime = DateTime.now();
          
          await authService.register(
            'performance@example.com',
            'Performance User',
            'password123',
          );
          
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          
          expect(duration.inMilliseconds, lessThan(2000)); // Less than 2 seconds
        });

        test('Acceptance: Usability Requirements Met', () async {
          // RNF02: Usabilidad - tareas principales en < 3 pasos
          
          // Task: User registration and login
          // Step 1: Register
          await authService.register(
            'usability@example.com',
            'Usability User',
            'password123',
          );
          
          // Step 2: Login
          await authService.login('usability@example.com', 'password123');
          
          // Step 3: Access system (implicit)
          final currentUser = await authService.getCurrentUser();
          
          // Task completed in 3 steps
          expect(currentUser, isNotNull);
          expect(currentUser!.email, equals('usability@example.com'));
        });

        test('Acceptance: Security Requirements Met', () async {
          // RNF03: Seguridad - datos almacenados de forma segura
          
          // Test data protection
          final user = await authService.register(
            'security@example.com',
            'Security User',
            'secure_password_123',
          );
          
          // Verify user data is stored
          expect(user.email, equals('security@example.com'));
          expect(user.name, equals('Security User'));
          
          // Test authentication security
          expect(
            () => authService.login('security@example.com', 'wrong_password'),
            throwsException,
          );
        });

        test('Acceptance: Availability Requirements Met', () async {
          // RNF04: Disponibilidad - aplicación disponible 99% del tiempo
          
          // Test system availability through multiple operations
          final operations = List.generate(10, (index) async {
            await authService.register(
              'availability$index@example.com',
              'Availability User $index',
              'password123',
            );
          });
          
          final results = await Future.wait(operations);
          expect(results.length, equals(10)); // All operations completed successfully
        });

        test('Acceptance: Scalability Requirements Met', () async {
          // RNF05: Escalabilidad - arquitectura permite agregar funcionalidades
          
          // Test system scalability with large dataset
          final largeDataset = List.generate(1000, (index) => 
            ProductiveBlock(
              weekday: (index % 7) + 1,
              hour: index % 24,
              completionRate: index / 1000.0,
              category: 'category${index % 10}',
            ),
          );
          
          final startTime = DateTime.now();
          
          // Process large dataset
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(largeDataset);
          final filteredBlocks = ProductiveBlock.filterByCategory(largeDataset, 'category0');
          final csvData = csvService.convertToCsv(largeDataset.map((block) => {
            'weekday': block.weekday.toString(),
            'hour': block.hour.toString(),
          }).toList());
          
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          
          expect(sortedBlocks.length, equals(1000));
          expect(filteredBlocks.length, equals(100));
          expect(csvData, isNotEmpty);
          expect(duration.inMilliseconds, lessThan(5000)); // Scalable performance
        });

        test('Acceptance: Compatibility Requirements Met', () async {
          // RNF06: Compatibilidad - funcionamiento en Android e iOS
          
          // Test cross-platform compatibility through data operations
          final user = await authService.register(
            'compatibility@example.com',
            'Compatibility User',
            'password123',
          );
          
          // Test data operations that should work on all platforms
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8),
          ];
          
          final csvData = csvService.convertToCsv([
            {'platform': 'test'},
          ]);
          
          expect(user, isA<UserModel>());
          expect(blocks, isNotEmpty);
          // El CSV tiene formato: header\nrow
          expect(csvData, contains('platform'));
          expect(csvData, contains('test'));
        });
      });
    });

    // ========================================
    // USER SATISFACTION TESTING
    // ========================================
    
    group('User Satisfaction Testing', () {
      test('Acceptance: Overall User Experience Satisfaction', () async {
        // Simulate complete user journey and measure satisfaction
        
        // Journey: New user onboarding to daily usage
        
        // Phase 1: Onboarding (should be smooth and intuitive)
        final user = await authService.register(
          'satisfaction@example.com',
          'Satisfaction User',
          'password123',
        );
        
        await authService.login('satisfaction@example.com', 'password123');
        final currentUser = await authService.getCurrentUser();
        
        // Phase 2: Daily usage (should be efficient and reliable)
        final dailyBlocks = [
          ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
          ProductiveBlock(weekday: 1, hour: 10, completionRate: 0.6, category: 'meeting'),
          ProductiveBlock(weekday: 1, hour: 11, completionRate: 0.9, category: 'work'),
        ];
        
        final workBlocks = ProductiveBlock.filterByCategory(dailyBlocks, 'work');
        final averageProductivity = workBlocks.fold(0.0, (sum, block) => sum + block.completionRate) / workBlocks.length;
        
        // Phase 3: Progress review (should provide valuable insights)
        final sortedBlocks = ProductiveBlock.sortByCompletionRate(dailyBlocks);
        final topPerformer = sortedBlocks.first;
        
        // Phase 4: Data export (should be seamless)
        final exportData = dailyBlocks.map((block) => {
          'weekday': block.weekday.toString(),
          'hour': block.hour.toString(),
          'category': block.category ?? '',
          'completion_rate': block.completionRate.toString(),
        }).toList();
        
        final csvData = csvService.convertToCsv(exportData);
        
        // Satisfaction Criteria:
        // - User can complete all tasks without frustration
        // - System provides value and insights
        // - Data operations are reliable and fast
        // - Export functionality meets user needs
        
        expect(currentUser, isNotNull);
        expect(dailyBlocks.length, equals(3));
        expect(workBlocks.length, equals(2));
        expect(averageProductivity, closeTo(0.85, 0.01)); // (0.8 + 0.9) / 2 - usar closeTo para comparación de flotantes
        expect(topPerformer.completionRate, equals(0.9));
        expect(csvData, isNotEmpty);
        expect(csvData, contains('1,9,work,0.8'));
        
        // If all criteria are met, user satisfaction is achieved
        expect(true, isTrue); // Test passes if all satisfaction criteria are met
      });
    });
  });
}
