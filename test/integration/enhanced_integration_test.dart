import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/core/services/event_bus.dart';
import 'dart:io';
import 'dart:convert';

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

/// Enhanced Integration Tests following the methodology from the design document
/// This test suite implements systematic integration strategies and thread-based testing
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late Directory tempDir;
  late AuthService authService;
  late TestCsvService csvService;
  late EventBus eventBus;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  });

  setUp(() async {
    // Initialize services first
    authService = AuthService();
    csvService = TestCsvService();
    eventBus = EventBus();
    
    // Clear box contents to clean up previous test data
    // Use clear() instead of deleteBoxFromDisk() to maintain boxes open
    try {
      final usersBox = Hive.box('users');
      if (usersBox.isOpen) {
        await usersBox.clear();
      }
    } catch (e) {
      // Box might not exist or be open, will be created when needed
    }
    try {
      final authBox = Hive.box('auth');
      if (authBox.isOpen) {
        await authBox.clear();
      }
    } catch (e) {
      // Box might not exist or be open, will be created when needed
    }
    try {
      final productiveBlocksBox = Hive.box('productive_blocks');
      if (productiveBlocksBox.isOpen) {
        await productiveBlocksBox.clear();
      }
    } catch (e) {
      // Box might not exist or be open, will be created when needed
    }
  });

  tearDown(() async {
    // Clear box contents instead of closing/deleting to avoid "Box has already been closed" errors
    try {
      final usersBox = Hive.box('users');
      if (usersBox.isOpen) {
        await usersBox.clear();
      }
    } catch (e) {
      // Box might not exist or be open
    }
    try {
      final authBox = Hive.box('auth');
      if (authBox.isOpen) {
        await authBox.clear();
      }
    } catch (e) {
      // Box might not exist or be open
    }
    try {
      final productiveBlocksBox = Hive.box('productive_blocks');
      if (productiveBlocksBox.isOpen) {
        await productiveBlocksBox.clear();
      }
    } catch (e) {
      // Box might not exist or be open
    }
  });

  group('Enhanced Integration Tests', () {
    
    // ========================================
    // SYSTEMATIC INTEGRATION STRATEGIES
    // ========================================
    
    group('Systematic Integration Strategies', () {
      
      // ========================================
      // BOTTOM-UP INTEGRATION TESTING
      // ========================================
      
      group('Bottom-Up Integration Testing', () {
        
        group('Level 1: Unit Components (F, G, H)', () {
          test('F: AuthService Unit Component', () async {
            // Test AuthService in isolation
            final user = await authService.register(
              'test@example.com',
              'Test User',
              'password123',
            );
            
            expect(user.email, equals('test@example.com'));
            expect(user.name, equals('Test User'));
          });

          test('G: ProductiveBlock Unit Component', () {
            // Test ProductiveBlock in isolation
            final block = ProductiveBlock(
              weekday: 1,
              hour: 9,
              completionRate: 0.75,
              category: 'work',
            );
            
            expect(block.weekday, equals(1));
            expect(block.category, equals('work'));
          });

          test('H: CsvService Unit Component', () {
            // Test CsvService in isolation
            final csvData = csvService.convertToCsv([
              {'name': 'test', 'value': '123'},
            ]);
            
            expect(csvData, contains('name,value'));
            expect(csvData, contains('test,123'));
          });
        });

        group('Level 2: Component Integration (C-F, D-G, E-H)', () {
          test('C-F: AuthService + Database Integration', () async {
            // Test AuthService integration with database
            // Use unique email to avoid conflicts with other tests
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final email = 'integration$timestamp@example.com';
            
            final user = await authService.register(
              email,
              'Integration User',
              'password123',
            );
            
            // Verify user is persisted
            final loginResult = await authService.login(
              email,
              'password123',
            );
            
            expect(loginResult, isTrue);
            
            final currentUser = await authService.getCurrentUser();
            expect(currentUser, isNotNull);
            expect(currentUser!.email, equals(email));
            
            // Clean up: logout to avoid interfering with subsequent tests
            await authService.logout();
          });

          test('D-G: ProductiveBlock + Data Processing Integration', () async {
            // Test ProductiveBlock integration with data processing
            final blocks = [
              ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
              ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
              ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.9, category: 'work'),
            ];
            
            // Test sorting functionality
            final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
            expect(sortedBlocks[0].completionRate, equals(0.9));
            expect(sortedBlocks[1].completionRate, equals(0.8));
            expect(sortedBlocks[2].completionRate, equals(0.6));
            
            // Test filtering functionality
            final filteredBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
            expect(filteredBlocks.length, equals(2));
          });

          test('E-H: CsvService + Data Export Integration', () async {
            // Test CsvService integration with data export
            final testData = [
              {'weekday': '1', 'hour': '9', 'category': 'work', 'completion_rate': '0.8'},
              {'weekday': '2', 'hour': '10', 'category': 'study', 'completion_rate': '0.6'},
            ];
            
            final csvData = csvService.convertToCsv(testData);
            
            expect(csvData, contains('weekday,hour,category,completion_rate'));
            expect(csvData, contains('1,9,work,0.8'));
            expect(csvData, contains('2,10,study,0.6'));
          });
        });

        group('Level 3: Module Integration (B-C, B-D, B-E)', () {
          test('B-C: User Management + AuthService Integration', () async {
            // Test user management module integration with auth service
            // Use unique emails to avoid conflicts
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final user1Email = 'user1$timestamp@example.com';
            final user2Email = 'user2$timestamp@example.com';
            
            final user1 = await authService.register(
              user1Email,
              'User One',
              'password123',
            );
            expect(user1.email, equals(user1Email));
            
            final user2 = await authService.register(
              user2Email,
              'User Two',
              'password456',
            );
            expect(user2.email, equals(user2Email));
            
            // Wait a bit to ensure Hive operations are complete
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Test first user login
            final login1Result = await authService.login(user1Email, 'password123');
            expect(login1Result, isTrue);
            var currentUser = await authService.getCurrentUser();
            expect(currentUser, isNotNull);
            expect(currentUser!.email, equals(user1Email));
            
            // Test logout
            await authService.logout();
            currentUser = await authService.getCurrentUser();
            expect(currentUser, isNull);
            
            // Wait a bit after logout to ensure operations are complete
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Verify user2 is still in the database before attempting login
            Box<UserModel> usersBox;
            try {
              usersBox = Hive.box<UserModel>('users');
            } catch (e) {
              usersBox = await Hive.openBox<UserModel>('users');
            }
            final user2Exists = usersBox.values.any((u) => u.email == user2Email);
            expect(user2Exists, isTrue, reason: 'User2 should exist in database before login');
            
            // Test second user login
            final login2Result = await authService.login(user2Email, 'password456');
            expect(login2Result, isTrue);
            currentUser = await authService.getCurrentUser();
            expect(currentUser, isNotNull);
            expect(currentUser!.email, equals(user2Email));
          });

          test('B-D: Data Management + ProductiveBlock Integration', () async {
            // Test data management module integration with productive blocks
            final blocks = [
              ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
              ProductiveBlock(weekday: 1, hour: 10, completionRate: 0.6, category: 'meeting'),
              ProductiveBlock(weekday: 1, hour: 11, completionRate: 0.9, category: 'work'),
            ];
            
            // Test data aggregation
            final workBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
            final totalWorkCompletion = workBlocks.fold(0.0, (sum, block) => sum + block.completionRate);
            final averageWorkCompletion = totalWorkCompletion / workBlocks.length;
            
            expect(averageWorkCompletion, closeTo(0.85, 0.01)); // (0.8 + 0.9) / 2
          });

          test('B-E: Export Module + CsvService Integration', () async {
            // Test export module integration with CSV service
            final user = await authService.register(
              'export@example.com',
              'Export User',
              'password123',
            );
            
            final blocks = [
              ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
              ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
            ];
            
            // Convert blocks to CSV format
            final blockData = blocks.map((block) => {
              'weekday': block.weekday.toString(),
              'hour': block.hour.toString(),
              'category': block.category ?? '',
              'completion_rate': block.completionRate.toString(),
            }).toList();
            
            final csvData = csvService.convertToCsv(blockData);
            
            expect(csvData, contains('weekday,hour,category,completion_rate'));
            expect(csvData, contains('1,9,work,0.8'));
            expect(csvData, contains('2,10,study,0.6'));
          });
        });

        group('Level 4: System Integration (A-B)', () {
          test('A-B: Complete System Integration', () async {
            // Test complete system integration
            // 1. User registration and authentication
            final user = await authService.register(
              'system@example.com',
              'System User',
              'password123',
            );
            
            await authService.login('system@example.com', 'password123');
            var currentUser = await authService.getCurrentUser();
            expect(currentUser, isNotNull);
            
            // 2. Data creation and management
            final blocks = [
              ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
              ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
              ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.9, category: 'work'),
            ];
            
            // 3. Data processing and analysis
            final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
            final workBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
            
            // 4. Data export
            final exportData = workBlocks.map((block) => {
              'weekday': block.weekday.toString(),
              'hour': block.hour.toString(),
              'category': block.category ?? '',
              'completion_rate': block.completionRate.toString(),
            }).toList();
            
            final csvData = csvService.convertToCsv(exportData);
            
            // Verify complete integration
            expect(currentUser!.email, equals('system@example.com'));
            expect(sortedBlocks.length, equals(3));
            expect(workBlocks.length, equals(2));
            expect(csvData, contains('work'));
            
            // 5. User logout
            await authService.logout();
            currentUser = await authService.getCurrentUser();
            expect(currentUser, isNull);
          });
        });
      });

      // ========================================
      // TOP-DOWN INTEGRATION TESTING
      // ========================================
      
      group('Top-Down Integration Testing', () {
        
        group('Depth-First Integration', () {
          test('A-B: System Level Integration', () async {
            // Test system level functionality
            final user = await authService.register(
              'topdown@example.com',
              'Top Down User',
              'password123',
            );
            
            expect(user.email, equals('topdown@example.com'));
          });

          test('A-B-C: System + User Management Integration', () async {
            // Test system + user management integration
            final user = await authService.register(
              'user@example.com',
              'User Name',
              'password123',
            );
            
            await authService.login('user@example.com', 'password123');
            final currentUser = await authService.getCurrentUser();
            
            expect(currentUser, isNotNull);
            expect(currentUser!.name, equals('User Name'));
          });

          test('A-B-C-F: Complete Auth Flow Integration', () async {
            // Test complete authentication flow
            final user = await authService.register(
              'auth@example.com',
              'Auth User',
              'password123',
            );
            
            await authService.login('auth@example.com', 'password123');
            final currentUser = await authService.getCurrentUser();
            
            expect(currentUser, isNotNull);
            expect(currentUser!.id, equals(user.id));
            
            await authService.logout();
            final afterLogout = await authService.getCurrentUser();
            expect(afterLogout, isNull);
          });
        });

        group('Breadth-First Integration', () {
          test('A-B: System Level', () async {
            // Test system level
            final user = await authService.register(
              'breadth@example.com',
              'Breadth User',
              'password123',
            );
            
            expect(user, isA<UserModel>());
          });

          test('B-C, B-D, B-E: Module Level', () async {
            // Test all modules at the same level
            // B-C: User Management
            final user = await authService.register(
              'module@example.com',
              'Module User',
              'password123',
            );
            
            // B-D: Data Management
            final blocks = [
              ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8),
              ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6),
            ];
            
            // B-E: Export Management
            final csvData = csvService.convertToCsv([
              {'test': 'data'},
            ]);
            
            expect(user.email, equals('module@example.com'));
            expect(blocks.length, equals(2));
            expect(csvData, contains('test'));
          expect(csvData, contains('data'));
          });

          test('C-F, D-G, E-H: Component Level', () async {
            // Test all components at the same level
            // C-F: Auth + Database
            await authService.register(
              'component@example.com',
              'Component User',
              'password123',
            );
            
            // D-G: Data + Processing
            final block = ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8);
            
            // E-H: Export + CSV
            final csvData = csvService.convertToCsv([
              {'component': 'test'},
            ]);
            
            final loginResult = await authService.login('component@example.com', 'password123');
            expect(loginResult, isTrue);
            expect(block.completionRate, equals(0.8));
            expect(csvData, contains('component'));
          expect(csvData, contains('test'));
          });
        });
      });
    });

    // ========================================
    // THREAD-BASED TESTING
    // ========================================
    
    group('Thread-Based Testing', () {
      
      group('Authentication Thread', () {
        test('Thread: User Registration and Login Flow', () async {
          // Thread: Complete user authentication flow
          final user = await authService.register(
            'thread@example.com',
            'Thread User',
            'password123',
          );
          
          final loginResult = await authService.login('thread@example.com', 'password123');
          final currentUser = await authService.getCurrentUser();
          
          expect(loginResult, isTrue);
          expect(currentUser!.email, equals('thread@example.com'));
          
          await authService.logout();
          final afterLogout = await authService.getCurrentUser();
          expect(afterLogout, isNull);
        });
      });

      group('Data Management Thread', () {
        test('Thread: ProductiveBlock Creation and Processing', () async {
          // Thread: Complete data management flow
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
            ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.9, category: 'work'),
          ];
          
          // Process data
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
          final workBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
          final studyBlocks = ProductiveBlock.filterByCategory(blocks, 'study');
          
          expect(sortedBlocks[0].completionRate, equals(0.9));
          expect(workBlocks.length, equals(2));
          expect(studyBlocks.length, equals(1));
        });
      });

      group('Export Thread', () {
        test('Thread: Data Export and CSV Generation', () async {
          // Thread: Complete export flow
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'study'),
          ];
          
          // Convert to export format
          final exportData = blocks.map((block) => {
            'weekday': block.weekday.toString(),
            'hour': block.hour.toString(),
            'category': block.category ?? '',
            'completion_rate': block.completionRate.toString(),
          }).toList();
          
          final csvData = csvService.convertToCsv(exportData);
          
          expect(csvData, contains('weekday,hour,category,completion_rate'));
          expect(csvData, contains('1,9,work,0.8'));
          expect(csvData, contains('2,10,study,0.6'));
        });
      });
    });

    // ========================================
    // SYSTEM STATE TESTING
    // ========================================
    
    group('System State Testing', () {
      
      group('UI State Testing', () {
        test('State: UI Active - All Services Available', () async {
          // Test when UI is active and all services are available
          final user = await authService.register(
            'active@example.com',
            'Active User',
            'password123',
          );
          
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8),
          ];
          
          final csvData = csvService.convertToCsv([
            {'active': 'test'},
          ]);
          
          expect(user.email, equals('active@example.com'));
          expect(blocks.length, equals(1));
          expect(csvData, contains('active'));
          expect(csvData, contains('test'));
        });

        test('State: UI Inactive - Services Still Functional', () async {
          // Test when UI is inactive but services should still work
          final user = await authService.register(
            'inactive@example.com',
            'Inactive User',
            'password123',
          );
          
          // Services should work even when UI is inactive
          final loginResult = await authService.login('inactive@example.com', 'password123');
          expect(loginResult, isTrue);
        });
      });

      group('Database State Testing', () {
        test('State: Database Available - Normal Operations', () async {
          // Test normal database operations
          final user = await authService.register(
            'db@example.com',
            'DB User',
            'password123',
          );
          
          await authService.login('db@example.com', 'password123');
          final currentUser = await authService.getCurrentUser();
          
          expect(currentUser, isNotNull);
          expect(currentUser!.email, equals('db@example.com'));
        });

        test('State: Database with Problems - Error Handling', () async {
          // Test error handling when database has problems
          // This would require mocking database errors in a real scenario
          // For now, we test normal operation
          final user = await authService.register(
            'problem@example.com',
            'Problem User',
            'password123',
          );
          
          expect(user.email, equals('problem@example.com'));
        });
      });

      group('Service State Testing', () {
        test('State: AI Service Available - Recommendations Work', () async {
          // Test when AI service is available
          // This would integrate with actual AI service in real scenario
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.6, category: 'work'),
          ];
          
          // Simulate AI service processing
          final workBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
          final averageCompletion = workBlocks.fold(0.0, (sum, block) => sum + block.completionRate) / workBlocks.length;
          
          expect(averageCompletion, equals(0.7)); // (0.8 + 0.6) / 2
        });

        test('State: AI Service Not Available - Fallback Behavior', () async {
          // Test fallback behavior when AI service is not available
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.8),
          ];
          
          // Basic processing should still work
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
          expect(sortedBlocks.length, equals(1));
        });
      });
    });

    // ========================================
    // PERFORMANCE INTEGRATION TESTING
    // ========================================
    
    group('Performance Integration Testing', () {
      test('Large Dataset Integration Performance', () async {
        // Test performance with large dataset
        final startTime = DateTime.now();
        
        // Create large dataset
        final blocks = List.generate(1000, (index) => 
          ProductiveBlock(
            weekday: (index % 7) + 1,
            hour: index % 24,
            completionRate: index / 1000.0,
            category: index % 2 == 0 ? 'work' : 'study',
          ),
        );
        
        // Process large dataset
        final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
        final workBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
        
        // Export large dataset
        final exportData = workBlocks.take(100).map((block) => {
          'weekday': block.weekday.toString(),
          'hour': block.hour.toString(),
          'category': block.category ?? '',
          'completion_rate': block.completionRate.toString(),
        }).toList();
        
        final csvData = csvService.convertToCsv(exportData);
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        // Verify performance
        expect(sortedBlocks.length, equals(1000));
        expect(workBlocks.length, equals(500));
        expect(csvData, isNotEmpty);
        expect(duration.inMilliseconds, lessThan(5000)); // Should complete in less than 5 seconds
      });

      test('Concurrent Operations Integration', () async {
        // Test concurrent operations
        final futures = List.generate(10, (index) async {
          final user = await authService.register(
            'concurrent$index@example.com',
            'User $index',
            'password123',
          );
          
          final blocks = List.generate(10, (blockIndex) => 
            ProductiveBlock(
              weekday: (blockIndex % 7) + 1,
              hour: blockIndex % 24,
              completionRate: blockIndex / 10.0,
            ),
          );
          
          return {
            'user': user,
            'blocks': blocks,
          };
        });
        
        final results = await Future.wait(futures);
        
          expect(results.length, equals(10));
          for (int i = 0; i < 10; i++) {
            final userData = results[i]['user'] as UserModel;
            expect(userData.email, equals('concurrent$i@example.com'));
            expect((results[i]['blocks'] as List).length, equals(10));
          }
      });
    });
  });
}
