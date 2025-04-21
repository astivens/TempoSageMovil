import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators/form_validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/services/speech_service.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _speechService = SpeechService();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _createTestUser();
  }

  Future<void> _createTestUser() async {
    await _authService.createInitialUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
        NavigationService.replaceTo('/home');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startVoiceCommand() async {
    final result = await _speechService.startListening();
    if (result != null) {
      // Procesar comandos como "login test@example.com password123"
      final parts = result.toLowerCase().split(' ');
      if (parts.isNotEmpty) {
        switch (parts[0]) {
          case 'login':
            if (parts.length >= 3) {
              _emailController.text = parts[1];
              _passwordController.text = parts[2];
              await _handleLogin();
            }
            break;
          case 'clear':
            _emailController.clear();
            _passwordController.clear();
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TEMPO',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SAGE',
                      style: TextStyle(
                        color: AppColors.mauve,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Welcome Text
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your account or create a new one',
                  style: TextStyle(
                    color: AppColors.subtext1,
                    fontSize: 14,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Login/Register Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface0,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.mauve,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to register
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.subtext0,
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:
                              const TextStyle(color: AppColors.subtext0),
                          filled: true,
                          fillColor: AppColors.surface0,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: AppColors.text),
                        validator: FormValidators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle:
                              const TextStyle(color: AppColors.subtext0),
                          filled: true,
                          fillColor: AppColors.surface0,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: AppColors.text),
                        validator: FormValidators.validatePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Voice Commands
                const Text(
                  'Try voice commands',
                  style: TextStyle(
                    color: AppColors.subtext1,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: _startVoiceCommand,
                  icon: const Icon(Icons.mic, color: AppColors.mauve),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface0,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
