import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;

  setUpAll(() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    authService = AuthService();
    await authService.createInitialUser();
  });

  test('should login, persist session and logout', () async {
    final loginResult = await authService.login('test@example.com', '12345678');
    expect(loginResult, true);
    final currentUser = await authService.getCurrentUser();
    expect(currentUser, isNotNull);
    await authService.logout();
    final afterLogout = await authService.getCurrentUser();
    expect(afterLogout, isNull);
  });
}
