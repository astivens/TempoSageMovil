class Env {
  static const String appName = 'TempoSage';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.temposage.com',
  );

  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  // Other Configuration
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);
}
