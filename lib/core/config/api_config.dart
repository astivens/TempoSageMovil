class ApiConfig {
  static const String openAIKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
}
